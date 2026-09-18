{ ... }:

{
  # nemo's "Open in Terminal" reads its command from the Cinnamon schema
  # org.cinnamon.desktop.default-applications.terminal, whose built-in default
  # is gnome-terminal — not installed here. nemo 6.6.4 only reads the `exec` key
  # (the sibling `exec-arg` string never appears in the binary), and it sets the
  # child's working directory itself, so `exec = "kitty"` is the whole fix.
  #
  # Written through dconf because nemo has no file-based config; the HM dconf
  # module only owns keys declared here, so nemo's own preferences still
  # round-trip through the same database.
  dconf.settings."org/cinnamon/desktop/applications/terminal".exec = "kitty";
}
