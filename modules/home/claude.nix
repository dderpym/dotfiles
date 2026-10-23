{ inputs, pkgs, lib, ... }:

let
  llm = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  mp = inputs.mattpocock-skills; # github:mattpocock/skills (flake = false)
  pt = inputs.ponytail;          # github:dietrichgebert/ponytail (flake = false)

  # mattpocock/skills + ponytail, pinned via flake inputs. Bump with `nix flake update`.
  # Claude Code discovers these from ~/.claude/skills/.
  skills = {
    # engineering
    codebase-design = "${mp}/skills/engineering/codebase-design";
    code-review = "${mp}/skills/engineering/code-review";
    diagnosing-bugs = "${mp}/skills/engineering/diagnosing-bugs";
    implement = "${mp}/skills/engineering/implement";
    improve-codebase-architecture = "${mp}/skills/engineering/improve-codebase-architecture";
    prototype = "${mp}/skills/engineering/prototype";
    resolving-merge-conflicts = "${mp}/skills/engineering/resolving-merge-conflicts";
    tdd = "${mp}/skills/engineering/tdd";
    to-spec = "${mp}/skills/engineering/to-spec";
    # productivity
    grilling = "${mp}/skills/productivity/grilling";
    teach = "${mp}/skills/productivity/teach";
    # dietrichgebert/ponytail
    ponytail = "${pt}/skills/ponytail";
    ponytail-audit = "${pt}/skills/ponytail-audit";
    ponytail-review = "${pt}/skills/ponytail-review";
  };

  settingsJson = pkgs.writeText "claude-settings.json" (builtins.toJSON {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";

    model = "claude-sonnet-5-5";

    # --- context trimming -------------------------------------------------
    includeGitInstructions = false;   # drop built-in commit/PR workflow prompt
    autoMemoryEnabled = false;        # no auto-written memory files injected
    disableBundledSkills = true;      # no bundled skills/workflows in the listing
    disableClaudeAiConnectors = true; # don't pull claude.ai MCP connectors
    syncClaudeAiSkills = false;       # don't pull claude.ai account skills
    syncClaudeAiPlugins = false;      # don't pull claude.ai account plugins
    enableArtifact = false;           # drop the Artifact tool
    enableWorkflows = false;          # no dynamic workflows / ultracode

    # --- background model calls / noise ------------------------------------
    promptSuggestionEnabled = false;  # grayed-out next-prompt suggestions
    awaySummaryEnabled = false;       # "while you were away" recap
    spinnerTipsEnabled = false;
    feedbackSurveyRate = 0;

    # no "Co-Authored-By: Claude" trailer / PR footer
    attribution = { commit = ""; pr = ""; };

    env = {
      DISABLE_AUTOUPDATER = "1";                      # nix owns the version
      CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"; # telemetry, error reports, etc.
    };
  });
in
{
  # claude-code from llm-agents, same as pi — shares the numtide cache.
  home.packages = [ llm.claude-code ];

  # Skills: store symlinks are fine (Claude only reads them). The parent dir
  # stays a real dir, so you can still drop ad-hoc skills in by hand.
  home.file = lib.mapAttrs' (name: src: {
    name = ".claude/skills/${name}";
    value = { source = src; };
  }) skills;

  # settings.json — Claude Code writes this itself (/model, /effort, /config).
  # A read-only store symlink silently drops those saves, so install a writable
  # copy at every activation: declared content wins on rebuild, runtime edits
  # survive until the next switch. (Account state lives in ~/.claude.json,
  # which we leave alone.)
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    mkdir -p "$HOME/.claude"
    install -m600 ${settingsJson} "$HOME/.claude/settings.json"
  '';
}
