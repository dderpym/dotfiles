{ pkgs, ... }:

let
  catLock = pkgs.runCommand "pinentry-cat-lock.png" { nativeBuildInputs = [ pkgs.librsvg ]; } ''
    rsvg-convert -w 128 -h 128 ${../../assets/pinentry/cat-lock.svg} > $out
  '';
  # Only UI resources/labels change; keep upstream's secret handling untouched.
  pinentry = pkgs.pinentry-qt.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      cp ${catLock} qt/icons/pinentry.png
      substituteInPlace qt/pinentrydialog.cpp \
        --replace-fail '_ok->setText(txt);' '_ok->setText(QStringLiteral("✓ ") + txt);' \
        --replace-fail '_cancel->setText(txt);' '_cancel->setText(QStringLiteral("× ") + txt);' \
        --replace-fail 'mShowHideButton = new QPushButton{this};' 'mShowHideButton = new QPushButton{this}; mShowHideButton->setFixedWidth(40);'
    '';
  });
in
{
  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentry = {
      # pinentry-all defaults to GTK2, which our Catppuccin theme does not cover.
      package = pinentry;
    };
    enableSshSupport = true;
    enableExtraSocket = true;
  };
}
