/*
 * Ambient-light backlight: a power curve over lux plus a user offset.
 *
 *   autobright daemon    poll the light sensor and ease the backlight to the curve
 *   autobright up|down   nudge the offset (brightness keys) and show a Noctalia OSD
 *   autobright status    print sensor, curve, offset and backlight; changes nothing
 */
#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <glob.h>
#include <math.h>
#include <spawn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#ifndef BRIGHTNESSCTL
#define BRIGHTNESSCTL "brightnessctl"
#endif

#define BACKLIGHT "intel_backlight"
#define BL_DIR "/sys/class/backlight/" BACKLIGHT

/* Curve: fraction = A * lux^K through two hand-picked points, floored. */
#define POINT_1_LUX 240.0
#define POINT_1_FRAC 0.136
#define POINT_2_LUX 3355.0
#define POINT_2_FRAC 0.617
#define FLOOR_FRAC 0.02 /* very dark */

/* Same perceptual curve as `brightnessctl -e` (its default exponent), so the
 * offset steps feel like the old brightness keys. */
#define EXPONENT 4.0
#define KEY_STEP 0.02

#define INTERVAL_S 5      /* seconds between sensor reads */
#define SMOOTHING 0.5     /* EMA weight of each new reading, in log-lux */
#define DEADBAND 0.01     /* ignore target moves smaller than this (perceptual) */
#define ADOPT_THRESHOLD 0.03 /* a bigger unexplained jump is a manual change */
#define FADE_STEP 0.01    /* max perceptual change per tick while fading */
#define FADE_TICK_MS 30
#define FADE_MAX_TICKS 200 /* give up if brightness refuses to move */

extern char **environ;

static double curve_a, curve_k;
static char offset_path[600];
static char state_dir[512];

static double clamp(double v, double lo, double hi)
{
	return v < lo ? lo : v > hi ? hi : v;
}

static void sleep_ms(long ms)
{
	struct timespec ts = { ms / 1000, (ms % 1000) * 1000000L };
	nanosleep(&ts, NULL);
}

static int read_number(const char *path, double *out)
{
	FILE *f = fopen(path, "r");
	int ok;

	if (!f)
		return -1;
	ok = fscanf(f, "%lf", out) == 1;
	fclose(f);
	return ok ? 0 : -1;
}

static void die(const char *msg)
{
	fprintf(stderr, "autobright: %s\n", msg);
	exit(1);
}

static int run_quiet(char *const argv[])
{
	posix_spawn_file_actions_t fa;
	pid_t pid;
	int status;

	posix_spawn_file_actions_init(&fa);
	posix_spawn_file_actions_addopen(&fa, 1, "/dev/null", O_WRONLY, 0);
	posix_spawn_file_actions_addopen(&fa, 2, "/dev/null", O_WRONLY, 0);
	if (posix_spawnp(&pid, argv[0], &fa, NULL, argv, environ) != 0) {
		posix_spawn_file_actions_destroy(&fa);
		return -1;
	}
	posix_spawn_file_actions_destroy(&fa);
	if (waitpid(pid, &status, 0) < 0)
		return -1;
	return status;
}

/* ---- sensor ---- */

static char als_path[256];

static void find_als(void)
{
	glob_t g;
	char probe[320];

	if (glob("/sys/bus/iio/devices/iio:device*", 0, NULL, &g) == 0) {
		for (size_t i = 0; i < g.gl_pathc; i++) {
			snprintf(probe, sizeof probe, "%s/in_illuminance_raw",
				 g.gl_pathv[i]);
			if (access(probe, R_OK) == 0) {
				snprintf(als_path, sizeof als_path, "%s",
					 g.gl_pathv[i]);
				break;
			}
		}
		globfree(&g);
	}
	if (!als_path[0])
		die("no ambient light sensor found");
}

static int cmp_double(const void *a, const void *b)
{
	double x = *(const double *)a, y = *(const double *)b;
	return (x > y) - (x < y);
}

/* Median of five reads, 100 ms apart, in lux. */
static double read_lux(void)
{
	char path[320];
	double scale = 1.0, samples[5];

	snprintf(path, sizeof path, "%s/in_illuminance_scale", als_path);
	if (read_number(path, &scale) != 0)
		scale = 1.0;
	snprintf(path, sizeof path, "%s/in_illuminance_raw", als_path);
	for (int i = 0; i < 5; i++) {
		double raw;

		if (read_number(path, &raw) != 0)
			die("cannot read light sensor");
		samples[i] = raw * scale;
		if (i < 4)
			sleep_ms(100);
	}
	qsort(samples, 5, sizeof samples[0], cmp_double);
	return samples[2];
}

/* ---- backlight ---- */

static double max_raw(void)
{
	static double max;

	if (max <= 0 && read_number(BL_DIR "/max_brightness", &max) != 0)
		die("cannot read max_brightness");
	return max;
}

static double current_raw(void)
{
	double raw;

	if (read_number(BL_DIR "/brightness", &raw) != 0)
		die("cannot read brightness");
	return raw;
}

static double current_p(void)
{
	return pow(current_raw() / max_raw(), 1.0 / EXPONENT);
}

static void set_p(double p)
{
	char buf[32];
	long raw = lround(max_raw() * pow(clamp(p, 0.0, 1.0), EXPONENT));
	char *argv[] = { BRIGHTNESSCTL, "-d", BACKLIGHT, "-q", "set", buf, NULL };

	if (raw < 1)
		raw = 1;
	snprintf(buf, sizeof buf, "%ld", raw);
	run_quiet(argv);
}

/* ---- curve and offset ---- */

static double curve_frac(double lux)
{
	if (lux <= 0)
		return FLOOR_FRAC;
	return clamp(curve_a * pow(lux, curve_k), FLOOR_FRAC, 1.0);
}

static double curve_p(double lux)
{
	return pow(curve_frac(lux), 1.0 / EXPONENT);
}

static double read_offset(void)
{
	double v;

	return read_number(offset_path, &v) == 0 ? v : 0.0;
}

static void write_offset(double v)
{
	char tmp[620];
	FILE *f;

	mkdir(state_dir, 0755);
	snprintf(tmp, sizeof tmp, "%s.tmp", offset_path);
	f = fopen(tmp, "w");
	if (!f)
		return;
	fprintf(f, "%.4f\n", v);
	if (fclose(f) == 0)
		rename(tmp, offset_path);
}

static double target_p(double lux)
{
	return clamp(curve_p(lux) + read_offset(), 0.0, 1.0);
}

/* ---- commands ---- */

static void daemon_loop(void)
{
	double smooth = 0, last_set = -1;
	int have_smooth = 0;

	for (;;) {
		double log_lux = log1p(read_lux());
		double lux, cur;

		if (!have_smooth) {
			smooth = log_lux;
			have_smooth = 1;
		} else {
			smooth += SMOOTHING * (log_lux - smooth);
		}
		lux = expm1(smooth);
		cur = current_p();

		/* Brightness moved by something other than us (Noctalia
		 * slider, ...): keep it by folding the difference into the
		 * offset. */
		if (last_set >= 0 && fabs(cur - last_set) > ADOPT_THRESHOLD)
			write_offset(cur - curve_p(lux));

		if (fabs(target_p(lux) - cur) >= DEADBAND) {
			/* Re-read the offset every tick so a key press mid-fade wins. */
			for (int tick = 0; tick < FADE_MAX_TICKS; tick++) {
				double goal = target_p(lux);

				cur = current_p();
				if (fabs(goal - cur) < FADE_STEP)
					cur = goal;
				else
					cur += copysign(FADE_STEP, goal - cur);
				set_p(cur);
				if (cur == goal)
					break;
				sleep_ms(FADE_TICK_MS);
			}
		}
		last_set = current_p();
		sleep(INTERVAL_S);
	}
}

static void nudge(int direction)
{
	double before = current_p();
	double after = clamp(before + direction * KEY_STEP, 0.0, 1.0);
	char text[48];
	char *argv[] = { "noctalia", "msg", "osd-show",
			 direction > 0 ? "brightness-up" : "brightness-down",
			 text, NULL };

	write_offset(read_offset() + (after - before));
	set_p(after);
	snprintf(text, sizeof text, "Brightness %ld%%", lround(after * 100));
	run_quiet(argv);
}

static void status(void)
{
	double lux = read_lux();

	printf("lux            %.1f\n", lux);
	printf("curve          %.1f%% raw\n", curve_frac(lux) * 100);
	printf("offset         %+.3f perceptual\n", read_offset());
	printf("target         %.1f%% raw\n",
	       pow(target_p(lux), EXPONENT) * 100);
	printf("backlight now  %.1f%% raw\n",
	       current_raw() / max_raw() * 100);
}

int main(int argc, char **argv)
{
	const char *cmd = argc > 1 ? argv[1] : "";
	const char *base = getenv("XDG_STATE_HOME");
	const char *home = getenv("HOME");

	curve_k = log(POINT_2_FRAC / POINT_1_FRAC) /
		  log(POINT_2_LUX / POINT_1_LUX);
	curve_a = POINT_1_FRAC / pow(POINT_1_LUX, curve_k);

	if (base && *base)
		snprintf(state_dir, sizeof state_dir, "%s/autobright", base);
	else if (home)
		snprintf(state_dir, sizeof state_dir,
			 "%s/.local/state/autobright", home);
	else
		die("neither XDG_STATE_HOME nor HOME is set");
	snprintf(offset_path, sizeof offset_path, "%s/offset", state_dir);

	if (!strcmp(cmd, "daemon")) {
		find_als();
		daemon_loop();
	} else if (!strcmp(cmd, "up") || !strcmp(cmd, "down")) {
		nudge(cmd[0] == 'u' ? 1 : -1);
	} else if (!strcmp(cmd, "status")) {
		find_als();
		status();
	} else {
		fprintf(stderr, "usage: autobright daemon|up|down|status\n");
		return 2;
	}
	return 0;
}
