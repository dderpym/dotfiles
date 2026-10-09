{ config, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "dderpym";
        email = "hithiswashardtoget@gmail.com";
        # Public key ID only; the signing key stays in the private GPG keyring.
        signingKey = "3B069D67734634DB";
      };
      gpg.format = "openpgp";
      commit.gpgSign = true;
      core.sshCommand = "ssh -i ~/.ssh/id_rsa";
    };
    ignores = [ "**/.claude/settings.local.json" ];
  };

  # Own the legacy location so the existing file cannot override HM's settings.
  xdg.configFile."git/config".target = "${config.home.homeDirectory}/.gitconfig";
}
