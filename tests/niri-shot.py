"""Run with: python3 tests/niri-shot.py /nix/store/...-niri-shot/bin/niri-shot

Mocks desktop commands; no real screenshots, notifications, or editor windows.
"""
import os
from pathlib import Path
import subprocess
import sys
import tempfile

source = Path(sys.argv[1]).read_text()
path_line = next(line for line in source.splitlines() if line.startswith("export PATH="))
runtime_path = path_line.removeprefix('export PATH="').removesuffix(':$PATH"')

with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    script = root / "niri-shot"
    script.write_text(source.replace(path_line, ""))
    script.chmod(0o755)
    commands = {
        "wayfreeze": '''echo running > "$FREEZE_STATE"
trap 'echo stopped > "$FREEZE_STATE"; exit 0' TERM
while :; do sleep 0.01; done''',
        "slurp": '''[ "${CANCEL:-0}" = 0 ] || exit 1
echo '0,0 100x100' ''',
        "niri": '''echo '{"logical":{"x":0,"y":0,"width":100,"height":100}}' ''',
        "grim": '''[ "${FAIL:-0}" = 0 ] || exit 1
printf capture > "$3"''',
        "wl-copy": 'cat > "$COPIED"',
        "notify-send": '''grep -q stopped "$FREEZE_STATE"
printf '%s\\n' "$@" > "$NOTICE"
printf '%s' "${ACTION:-}"''',
        "satty": '''cat "$2" > "$EDITED"
printf '%s\\n' "$@" > "$EDITOR_ARGS"''',
    }
    for name, body in commands.items():
        command = root / name
        command.write_text("#!/usr/bin/env bash\nset -eu\n" + body + "\n")
        command.chmod(0o755)
    captures = root / "tmp"
    captures.mkdir()
    environment = os.environ | {
        "PATH": f"{root}:{runtime_path}:{os.environ['PATH']}",
        "HOME": str(root),
        "TMPDIR": str(captures),
        "FREEZE_STATE": str(root / "freeze"),
        "COPIED": str(root / "copied"),
        "NOTICE": str(root / "notice"),
        "EDITED": str(root / "edited"),
        "EDITOR_ARGS": str(root / "editor-args"),
    }

    for mode in ("region", "full"):
        for destination in ("clip", "file"):
            for action in ("", "default", "edit"):
                for name in ("copied", "notice", "edited", "editor-args"):
                    (root / name).unlink(missing_ok=True)
                for image in (root / "Pictures").glob("*.png"):
                    image.unlink()
                subprocess.run(
                    [str(script), mode, destination],
                    env=environment | {"ACTION": action}, check=True, timeout=5,
                )
                assert (root / "freeze").read_text().strip() == "stopped"
                assert not list(captures.iterdir()), "Temporary capture leaked"
                assert (root / "copied").exists() == (destination == "clip")
                assert bool(list((root / "Pictures").glob("*.png"))) == (destination == "file")
                assert "--action=default=Edit" in (root / "notice").read_text()
                assert (root / "edited").exists() == bool(action)
                if action:
                    assert (root / "edited").read_text() == "capture"
                    expected = "save-to-clipboard" if destination == "clip" else "save-to-file"
                    assert f"{expected},exit" in (root / "editor-args").read_text()

    for override, expected_code in (({"CANCEL": "1"}, 0), ({"FAIL": "1"}, 1)):
        (root / "notice").unlink(missing_ok=True)
        result = subprocess.run(
            [str(script), "region", "clip"], env=environment | override, timeout=5,
        )
        assert result.returncode == expected_code
        assert not (root / "notice").exists()
        assert not list(captures.iterdir())
        # Failed/cancelled captures kill the freeze process through the exit trap.
        assert (root / "freeze").read_text().strip() == "stopped"

print("PASS: capture modes, destinations, notification actions, unfreeze, and cleanup")
