# niri-shot: region/full screenshot helper, bound in niri.nix (Mod+S etc.).
# Declarative so the script and its runtime deps are reproducible (previously
# lived ad-hoc in ~/.local/bin).
{ pkgs }:

pkgs.writeShellApplication {
  name = "niri-shot";
  runtimeInputs = with pkgs; [
    coreutils # date, mkdir, sleep
    grim
    jq
    libnotify # notify-send
    niri # niri msg focused-output
    slurp
    wayfreeze
    wl-clipboard # wl-copy
  ];
  text = ''
    # Arguments: $1 = region/full, $2 = clip/file
    # (writeShellApplication runs this with set -euo pipefail, so every
    # fallible command is guarded — e.g. a cancelled slurp must still unfreeze)
    SAVE_DIR="$HOME/Pictures"
    FILENAME="$SAVE_DIR/$(date +%Y-%m-%d_%H-%M-%S).png"

    unfreeze() {
      kill "$FREEZE_PID" 2>/dev/null || true
    }

    # Start the freeze
    wayfreeze &
    FREEZE_PID=$!

    # Give wayfreeze a moment to map the surface
    sleep 0.1

    if [ "''${1:-region}" = "region" ]; then
      GEOM=$(slurp -b "#45858844" -c "#83a598ff") || { unfreeze; exit 1; }
    else
      # Geometry of the focused monitor (logical coords — `niri msg outputs` has
      # no `focused` field, so use the dedicated focused-output command)
      GEOM=$(niri msg -j focused-output | jq -r '"\(.logical.x),\(.logical.y) \(.logical.width)x\(.logical.height)"') || { unfreeze; exit 1; }
    fi

    # Take the shot and handle destination
    if [ "''${2:-clip}" = "clip" ]; then
      grim -g "$GEOM" - | wl-copy
      notify-send "Screenshot" "Copied to clipboard" -i camera-photo
    else
      mkdir -p "$SAVE_DIR"
      grim -g "$GEOM" "$FILENAME"
      notify-send "Screenshot Saved" "$FILENAME" -i camera-photo
    fi

    # Unfreeze the screen
    unfreeze
  '';
}
