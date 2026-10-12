{ inputs, pkgs, lib, ... }:

let
  mp = inputs.mattpocock-skills; # github:mattpocock/skills (flake = false)
  pt = inputs.ponytail;          # github:dietrichgebert/ponytail (flake = false)

  llm = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  # The 14 skills pi runs, mapped to their pinned source dirs. Bump with
  # `nix flake update`. pi discovers these from ~/.pi/agent/skills/.
  skills = {
    # mattpocock/skills — engineering
    codebase-design = "${mp}/skills/engineering/codebase-design";
    code-review = "${mp}/skills/engineering/code-review";
    diagnosing-bugs = "${mp}/skills/engineering/diagnosing-bugs";
    implement = "${mp}/skills/engineering/implement";
    improve-codebase-architecture = "${mp}/skills/engineering/improve-codebase-architecture";
    prototype = "${mp}/skills/engineering/prototype";
    resolving-merge-conflicts = "${mp}/skills/engineering/resolving-merge-conflicts";
    tdd = "${mp}/skills/engineering/tdd";
    to-spec = "${mp}/skills/engineering/to-spec";
    # mattpocock/skills — productivity
    grilling = "${mp}/skills/productivity/grilling";
    teach = "${mp}/skills/productivity/teach";
    # dietrichgebert/ponytail
    ponytail = "${pt}/skills/ponytail";
    ponytail-audit = "${pt}/skills/ponytail-audit";
    ponytail-review = "${pt}/skills/ponytail-review";
  };

  settingsJson = pkgs.writeText "pi-settings.json" (builtins.toJSON {
    npmCommand = [ "bun" ];
    theme = "dark";
    defaultProvider = "openai-codex";
    defaultModel = "gpt-6.1-sol";
    defaultThinkingLevel = "high";
    packages = [
      "npm:@iiwate/pi-subagents-lite"
      "npm:pi-cache-optimizer"
      "npm:@ff-labs/pi-fff"
      "npm:pi-lsp"
      "npm:@petechu/pi-extension-toggle"
      "npm:@kreeger/pi-edit-split"
      "npm:pi-agent-browser-native"
      "npm:pi-smart-web-search"
      "npm:pi-smart-fetch"
      "npm:pi-btw"
    ];
  });

  modelsJson = pkgs.writeText "pi-models.json" (builtins.toJSON {
    providers.deepseek.compat = {
      supportsLongCacheRetention = true;
      sendSessionAffinityHeaders = true;
    };
  });
in
{
  # pi binary from llm-agents (bun-compiled; ships fd/ripgrep itself), plus
  # the runtime deps it needs for package management (bun/node/uv) and browser
  # automation (agent-browser + chromium via playwright). Was previously a
  # wrapped package in pkgs/pi/flake.nix; folded in here so llm-agents' pi is
  # used directly. llm-agents keeps its own nixpkgs (unstable) so
  # cache.numtide.com hits — see the input comment in flake.nix.
  home.packages = [
    llm.pi
    llm.agent-browser
    pkgs.bun
    pkgs.nodejs_24
    pkgs.uv
    pkgs.chromium
    pkgs.playwright-driver.browsers
  ];

  # playwright must use the nix-provided browsers instead of downloading its
  # own (which fails on NixOS). Exported session-wide; harmless single-user.
  home.sessionVariables = {
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
  };

  # Skills: pinned from flake inputs, symlinked into pi's skill dir. pi only
  # reads skills, so store symlinks are fine. The parent dir stays a real dir,
  # so pi can still add new skills at runtime.
  #
  # models.json — static provider config pi never writes (verified); safe as a
  # read-only store symlink.
  home.file = (lib.mapAttrs' (name: src: {
    name = ".pi/agent/skills/${name}";
    value = { source = src; };
  }) skills) // {
    ".pi/agent/models.json" = {
      source = modelsJson;
      force = true;
    };
  };

  # settings.json — pi writes this file itself (`pi install`, `/settings`,
  # lastChangelogVersion). A read-only store symlink makes `pi install` fail
  # silently, so install a writable copy at every activation: declared content
  # wins on rebuild, runtime edits survive between switches. Preserve pi's
  # runtime lastChangelogVersion so it doesn't re-show the changelog every
  # rebuild.
  home.activation.piSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    target="$HOME/.pi/agent/settings.json"
    mkdir -p "$(dirname "$target")"
    if [ -f "$target" ]; then
      prev=$(${pkgs.jq}/bin/jq -r '.lastChangelogVersion // empty' "$target" 2>/dev/null || true)
      if [ -n "$prev" ]; then
        ${pkgs.jq}/bin/jq --arg v "$prev" '.lastChangelogVersion = $v' ${settingsJson} > "$target.new" \
          && chmod 600 "$target.new" && mv "$target.new" "$target"
      else
        install -m600 ${settingsJson} "$target"
      fi
    else
      install -m600 ${settingsJson} "$target"
    fi
  '';
}
