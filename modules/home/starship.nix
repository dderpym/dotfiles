{ ... }:
let
  mkLang = symbol: {
    inherit symbol;
    style = "bg:green";
    format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
  };
in
{
  programs.starship.settings = {
    add_newline = false;

    # One continuous powerline chain: red → peach → yellow → green → sapphire
    # → lavender, closing on the character, which carries its own notch pair
    # (see character.* below) so the prompt reads "… ❯  ".
    format = builtins.concatStringsSep "" [
      "$os$username"
      "[](fg:prev_bg bg:peach)$directory"
      "[](fg:prev_bg bg:yellow)$git_branch$git_status"
      "$character"
    ];

    right_format = builtins.concatStringsSep "" [
      "$nodejs$bun$python$rust$golang$php$java$kotlin$haskell"
      "[](fg:prev_bg bg:sapphire)$conda"
      "[](fg:prev_bg bg:lavender)$cmd_duration"
    ];


    palette = "catppuccin_mocha";

    os = {
      disabled = false;
      style = "bg:red fg:crust";
      symbols = {
        Windows = "";
        Ubuntu = "󰕈";
        SUSE = "";
        Raspbian = "󰐿";
        Mint = "󰣭";
        Macos = "󰀵";
        Manjaro = "";
        Linux = "󰌽";
        # NixOS is detected as its own OS by the os module; without this the
        # default snowflake emoji (❄️) renders, which flyline miscounts as
        # single-width while kitty renders it double-width — making the
        # prompt walk down one row per keystroke.
        NixOS = "󰌽";
        Gentoo = "󰣨";
        Fedora = "󰣛";
        Alpine = "";
        Amazon = "";
        Android = "";
        AOSC = "";
        Arch = "󰣇";
        Artix = "󰣇";
        CentOS = "";
        Debian = "󰣚";
        Redhat = "󱄛";
        RedHatEnterprise = "󱄛";
      };
    };

    username = {
      show_always = true;
      style_user = "bg:red fg:crust";
      style_root = "bg:red fg:crust";
      format = "[ $user]($style)";
    };

    directory = {
      style = "bg:peach fg:crust";
      format = "[ $path ]($style)";
      truncation_length = 3;
      truncation_symbol = "…/";
      substitutions = {
        "Documents" = "󰈙 ";
        "Downloads" = " ";
        "Music" = "󰝚 ";
        "Pictures" = " ";
        "Developer" = "󰲋 ";
      };
    };

    git_branch = {
      symbol = "";
      style = "bg:yellow";
      format = "[[ $symbol $branch ](fg:crust bg:yellow)]($style)";
    };

    git_status = {
      style = "bg:yellow";
      format = "[[($all_status$ahead_behind )](fg:crust bg:yellow)]($style)";
    };

    c = mkLang " ";
    rust = mkLang "";
    golang = mkLang "";
    nodejs = mkLang "";
    bun = mkLang "";
    php = mkLang "";
    java = mkLang " ";
    kotlin = mkLang "";
    haskell = mkLang "";
    python = mkLang "" // {
      format = "[[ $symbol( $version)(\(#$virtualenv\)) ](fg:crust bg:green)]($style)";
    };

    conda = {
      symbol = "  ";
      style = "fg:crust bg:sapphire";
      format = "[$symbol$environment ]($style)";
      ignore_base = false;
    };

    cmd_duration = {
      show_milliseconds = true;
      style = "fg:crust bg:lavender";
      format = "[ in $duration]($style)";
      disabled = false;
      show_notifications = true;
      min_time_to_notify = 45000;
    };

    character = {
      disabled = false;
      success_symbol = "[](fg:prev_bg bg:green)[ \\$ ](fg:crust bg:green)[](fg:green)";
      error_symbol = "[](fg:prev_bg bg:red)[ \\$ ](fg:crust bg:red)[](fg:red)";
    };
  };
}
