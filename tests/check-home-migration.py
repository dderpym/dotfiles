"""Check migrated HM modules without activating them or reading private keys."""

import json
import os
import pwd
from pathlib import Path
import subprocess
import tempfile

REPO = Path(__file__).resolve().parents[1]


def command(*args, env=None):
    return subprocess.check_output(args, cwd=REPO, env=env, text=True).strip()


with tempfile.TemporaryDirectory(prefix="hm-migration-") as tmp:
    home = Path(tmp) / "home with spaces"
    runtime = Path(tmp) / "runtime"
    env = dict(os.environ, HM_TEST_HOME=str(home), XDG_RUNTIME_DIR=str(runtime))
    expression = '''
      let
        flake = builtins.getFlake (toString ./.);
        cfg = (import (flake.inputs.home-manager + "/modules") {
          pkgs = flake.nixosConfigurations.stoletop.pkgs;
          configuration = {
            imports = [
              ./modules/home/gpg.nix
              ./modules/home/git.nix
              ./modules/home/ssh.nix
              ./modules/home/neovim.nix
            ];
            home.username = "migration-test";
            home.homeDirectory = builtins.getEnv "HM_TEST_HOME";
            home.stateVersion = "25.11";
          };
        }).config;
      in {
        git = cfg.xdg.configFile."git/config".text;
        ignores = cfg.xdg.configFile."git/ignore".text;
        gitTarget = cfg.home.file."${cfg.xdg.configHome}/git/config".target;
        ssh = cfg.home.file.".ssh/config".text;
        sshDirectory = cfg.home.activation.sshDirectory.data;
        state = cfg.home.activation.neovimState.data;
        failures = map (a: a.message) (builtins.filter (a: !a.assertion) cfg.assertions);
      }
    '''
    config = json.loads(command("nix", "eval", "--impure", "--json", "--expr", expression, env=env))
    assert not config["failures"], config["failures"]
    assert config["gitTarget"] == ".gitconfig"
    assert config["ignores"].splitlines() == ["**/.claude/settings.local.json"]
    assert (REPO / "assets/wallpapers/p4g.png").read_bytes()[:8] == b"\x89PNG\r\n\x1a\n"

    git_config = Path(tmp) / "gitconfig"
    git_config.write_text(config["git"])
    for setting, expected in {
        "user.name": "dderpym",
        "user.email": "hithiswashardtoget@gmail.com",
        "user.signingkey": "3B069D67734634DB",
        "gpg.format": "openpgp",
        "commit.gpgsign": "true",
        "core.sshcommand": "ssh -i ~/.ssh/id_rsa",
    }.items():
        assert command("git", "config", "--file", str(git_config), "--get", setting) == expected

    ssh_config = Path(tmp) / "sshconfig"
    ssh_config.write_text(config["ssh"])
    for host, user in {
        "austin-1": "ubuntu", "calsol": "ec2-user", "oci-birdwax": "ubuntu",
        "oci-ostrichwax": "ubuntu", "github.com": "git", "unlisted-host": pwd.getpwuid(os.getuid()).pw_name,
    }.items():
        effective = dict(line.split(" ", 1) for line in command(
            "ssh", "-G", "-T", "-F", str(ssh_config), host, env=env
        ).splitlines())
        assert effective["user"] == user
        assert effective["forwardagent"] == "no"
        assert effective["hashknownhosts"] == "yes"
        assert effective["stricthostkeychecking"] == "ask"
        assert effective["identityagent"] == str(runtime / "gnupg/S.gpg-agent.ssh")
        if host == "github.com":
            assert effective["identitiesonly"] == "yes"
            assert effective["identityfile"] == "~/.ssh/id_rsa"

    # Execute only our own snippets, not Home Manager's activation script.
    prefix = "set -eu\nrun() { \"$@\"; }\n"
    subprocess.run(["bash", "-c", prefix + config["sshDirectory"]], env=env, check=True)
    assert (home / ".ssh").stat().st_mode & 0o777 == 0o700
    script = prefix + config["state"]
    subprocess.run(["bash", "-c", script], env=env, check=True)
    for name in ["lazy-lock.json", "lazyvim.json"]:
        path = home / ".config/nvim" / name
        assert json.loads(path.read_text()) == json.loads((REPO / "modules/home/nvim" / name).read_text())
        assert path.stat().st_mode & 0o777 == 0o600
        path.write_text('{"local_update": true}\n')
    subprocess.run(["bash", "-c", script], env=env, check=True)
    assert all(json.loads((home / ".config/nvim" / name).read_text()) == {"local_update": True}
               for name in ["lazy-lock.json", "lazyvim.json"])
    lock = home / ".config/nvim/lazy-lock.json"
    lock.unlink()
    lock.symlink_to(Path(tmp) / "missing-target")
    subprocess.run(["bash", "-c", script], env=env, check=True)
    assert lock.is_symlink() and not lock.exists()

print("Git/SSH settings and non-destructive Neovim seeding: OK")
