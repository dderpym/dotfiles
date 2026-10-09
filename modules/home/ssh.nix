{ config, lib, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        ForwardAgent = false;
        HashKnownHosts = true;
        StrictHostKeyChecking = "ask";
        # Use the managed GPG socket even when a desktop sets SSH_AUTH_SOCK.
        IdentityAgent = lib.replaceStrings [ "%t" ] [ "\${XDG_RUNTIME_DIR}" ]
          config.systemd.user.sockets.gpg-agent-ssh.Socket.ListenStream;
      };
      "austin-1" = {
        HostName = "34.173.193.187";
        User = "ubuntu";
        Port = 22;
      };
      "calsol" = {
        HostName = "44.244.120.30";
        User = "ec2-user";
        Port = 22;
      };
      "oci-birdwax" = {
        HostName = "birdwax.duckdns.org";
        User = "ubuntu";
      };
      "oci-ostrichwax" = {
        HostName = "ostrichwax.duckdns.org";
        User = "ubuntu";
      };
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/id_rsa";
        IdentitiesOnly = true;
      };
    };
  };

  home.activation.sshDirectory = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run ${pkgs.coreutils}/bin/install -d -m700 ${lib.escapeShellArg "${config.home.homeDirectory}/.ssh"}
  '';
}
