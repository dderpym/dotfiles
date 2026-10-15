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
    satty
    slurp
    wayfreeze
    wl-clipboard
  ];
  text = ''
    SAVE_DIR="$HOME/Pictures"
    FILENAME="$SAVE_DIR/$(date +%Y-%m-%d_%H-%M-%S).png"
    CAPTURE=$(mktemp --suffix=.png)

    wayfreeze &
    FREEZE_PID=$!
    # Keep clipboard captures available to the editor without saving to Pictures.
    trap 'kill "$FREEZE_PID" 2>/dev/null || true; wait "$FREEZE_PID" 2>/dev/null || true; rm -f -- "$CAPTURE"' EXIT
    sleep 0.1

    if [ "''${1:-region}" = "region" ]; then
      GEOM=$(slurp -b "#45858844" -c "#83a598ff") || exit 0
    else
      GEOM=$(niri msg -j focused-output | jq -er '"\(.logical.x),\(.logical.y) \(.logical.width)x\(.logical.height)"')
    fi

    grim -g "$GEOM" "$CAPTURE"
    kill "$FREEZE_PID" 2>/dev/null || true
    wait "$FREEZE_PID" 2>/dev/null || true
    trap 'rm -f -- "$CAPTURE"' EXIT

    if [ "''${2:-clip}" = "clip" ]; then
      wl-copy < "$CAPTURE"
      SUMMARY="Screenshot"
      BODY="Copied to clipboard — click to edit"
      EDIT_ACTION="save-to-clipboard"
    else
      mkdir -p "$SAVE_DIR"
      cp -- "$CAPTURE" "$FILENAME"
      SUMMARY="Screenshot Saved"
      BODY="$FILENAME — click to edit"
      EDIT_ACTION="save-to-file"
    fi

    ACTION=$(notify-send "$SUMMARY" "$BODY" -i camera-photo \
      --action=default=Edit --action=edit=Edit)
    if [ "$ACTION" = "default" ] || [ "$ACTION" = "edit" ]; then
      mkdir -p "$SAVE_DIR"
      satty --filename "$CAPTURE" --output-filename "$FILENAME" \
        --copy-command wl-copy --actions-on-enter "$EDIT_ACTION,exit"
    fi
  '';
}
