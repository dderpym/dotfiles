{ ... }:

{
  programs.kitty = {
    enable = true;
    shellIntegration = {
      enableBashIntegration = true;
      mode = "enabled";
    };
    settings = {
      confirm_os_window_close = -1;
    };
  };
}
