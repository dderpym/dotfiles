# AGENTS.md — working on this NixOS flake

Field notes for agentic work on NixOS dotfiles. Nix changes fast; training
memory rots. Everything below is about establishing ground truth cheaply and
validating end-to-end before declaring victory.

## Ground truth, in order of trust

1. **Your locked revs + installed binaries** — `flake.lock` pins exact nixpkgs
   revs; `/nix/store` holds the actual source, binaries, and generated configs.
   This is the only thing that's true *for this machine*.
2. **Official manuals at matching versions** — nix.dev, the NixOS manual,
   home-manager manual. Read the version that matches your lock, not `latest`.
3. **Option reference sites** (MyNixOS, extranix home-manager search) — fast
   for "does this option exist", but they track a rev you may not be on.
4. **Community** (NixOS discourse, wiki, Reddit) — great for tradeoffs and
   consensus ("auto-optimise-store vs timer", "max-jobs vs cores"), unreliable
   for names and defaults.
5. **Training-data memory** — treat as a hypothesis, verify before applying.

## Getting the source of YOUR nixpkgs

```sh
# Source checkout of the nixpkgs your system actually uses:
nix eval --raw .#nixosConfigurations.<host>.pkgs.path
```

Then grep it. Module files move between releases (e.g. `nix-daemon.nix` moved
from `services/misc/` to `services/system/` in 26.05) — search the whole tree
rather than assuming a path.

**Settings ground truth:** doc sites lag behind renames (`parallel-downloads`
→ `http-connections`). The installed nix binary lists every accepted setting:

```sh
ls -d /nix/store/*-nix-*/bin/nix | head -1 | xargs -I{} {}/nix config show
```

## Validation ladder — go up only as far as the change requires

| Step | Catches | Cost |
|------|---------|------|
| `nix flake lock` | input/follows graph issues; prunes dead nodes | seconds |
| `nix flake check` | eval errors: unknown options in *your* config, type errors, module merge problems | ~1 min (cached) |
| `nixos-rebuild build --flake .` | **build-time validation** — generated `nix.conf` parsing, unit/service generation, activation scripts | minutes (mostly cached) |
| `nixos-rebuild switch` | — | the real deal |

**The critical gap:** `nix flake check` does *not* run builders. The
`nix.conf.drv` step that validates `nix.settings.*` values happens at build
time only. After touching anything under `nix.settings.*`, run
`nixos-rebuild build` — a passing flake check proves nothing there.

Debugging a failed build: the error prints the failing drv path
(`/nix/store/...-nix.conf.drv`). Reproduce and inspect with
`nix log <drv>` / `nix build <drv>`. Also read the *generated* output, not
just "build succeeded":

```sh
cat /nix/store/*-nixos-system-*/etc/nix/nix.conf
```

## flake.lock hygiene

- **Duplicate `_2` nodes** (`nixpkgs_2`, `llm-agents_2`, `bun2nix_2`…) mean the
  same input is being resolved twice — usually a missing `follows`. Dump the
  graph with `nix flake metadata --json` and read the `inputs` edges.
- **`follows` is the dedup tool**: `inputs.X.inputs.nixpkgs.follows = "nixpkgs"`.
  After changing follows, `nix flake lock` prunes the now-dead nodes; compare
  node count before/after.
- **Path inputs (subflakes)** are resolved by the *parent's* `flake.lock` —
  their declared inputs get locked into it (with `_2` suffixes when duplicated).
  No `flake.lock` needed inside the subflake.
- **Dead vs hub inputs:** an input may be unused by your outputs but still
  required as a `follows` target. Grep for `inputs.<name>` to tell which is
  which before deleting.
- **Transient failures are real:** the first `nix flake lock` after editing a
  path input can fail with a git race ("cannot create an empty blob…"). Re-run
  once before investigating; verify with `nix flake metadata`.
- **Aim for few nixpkgs revisions:** one for the system; a second only when a
  dependency must keep its own (e.g. to hit a project's binary cache). Document
  *why* in a comment at the input declaration.

## Research workflow for nix questions

1. Web-search the exact option/module name + `nixos`/`home-manager` — the most
   useful results are MyNixOS option pages, the official manual, and discourse
   threads.
2. `batch_web_fetch` the 2–3 top results in parallel (discourse pages fetch
   cleanly).
3. For *semantic* questions (which of two options, what's the tradeoff),
   prefer the official manual plus a community-consensus thread over blog
   posts; blogs are where stale names live.
4. Always re-confirm against your locked rev + installed binary (sections
   above) — names change across releases.
5. When giving performance advice, cite the actual default values from the
   installed version and label things "real win" vs "marginal tweak".

## Review instincts for "is this dead / weird?"

- **Read git history for intent.** Commit messages explain *why* things exist
  ("flyline over blesh (blesh too slow)", "duplicate gpgtty"). A weird bit of
  config with a explaining commit is usually intentional.
- Classic dead-code patterns: a module imported twice (once in the flake's
  `modules`, once via another file's `imports`); inputs declared but never
  referenced; commented-out blocks superseded by a newer mechanism (e.g. a
  commented `programs.gnupg.agent` block after gpg moved to home-manager);
  options set then overridden elsewhere.
- `stateVersion` is *deliberately* old in most setups — flag it, never "fix" it.
- When the user's mental model conflicts with the evidence, show the evidence
  (lock file, `nix config show`, generated config) instead of just asserting.
- Separate findings into broken / dead / weird / verified-fine, and say which
  is which. Don't cargo-cult cleanups that change semantics (e.g. forcing a
  dependency off its own nixpkgs would silently kill binary-cache hits).

## Habits that worked

- After each edit batch, run the cheapest gate that covers the *class* of
  change you made: inputs → `nix flake lock`; modules/options →
  `nix flake check`; `nix.settings.*` → `nixos-rebuild build`.
- Comment config with the *reason* (cache compatibility, rename history), not
  the what — the Nix expression already shows the what.
- The nix store is a debugging toolbox: source checkouts, generated configs,
  built binaries with their own `--version` and `config show`. Use them.
- Verify generated artifacts on disk, never just eval success.
- Let the user drive: propose the tradeoff (timer vs per-build optimise,
  follow vs keep-own-nixpkgs), apply what they choose, and keep changes
  reviewable in one commit per logical cleanup.
