# Separate capture mode and destination for the four screenshot shortcuts.
{ pkgs }:

pkgs.writeShellApplication {
  name = "niri-shot";
  runtimeInputs = with pkgs; [
    coreutils
    grim
    jq
    libnotify
    niri
    slurp
    wayfreeze
    wl-clipboard
  ];
  text = ''
    SAVE_DIR="$HOME/Pictures"
    FILENAME="$SAVE_DIR/$(date +%Y-%m-%d_%H-%M-%S).png"

    wayfreeze &
    FREEZE_PID=$!
    # Always unfreeze, including cancelled selection or failed capture.
    trap 'kill "$FREEZE_PID" 2>/dev/null || true' EXIT
    sleep 0.1

    if [ "''${1:-region}" = "region" ]; then
      GEOM=$(slurp -b "#45858844" -c "#83a598ff") || exit 0
    else
      GEOM=$(niri msg -j focused-output | jq -er '"\(.logical.x),\(.logical.y) \(.logical.width)x\(.logical.height)"')
    fi

    if [ "''${2:-clip}" = "clip" ]; then
      grim -g "$GEOM" - | wl-copy
      notify-send "Screenshot" "Copied to clipboard" -i camera-photo
    else
      mkdir -p "$SAVE_DIR"
      grim -g "$GEOM" "$FILENAME"
      notify-send "Screenshot Saved" "$FILENAME" -i camera-photo
    fi
  '';
}
