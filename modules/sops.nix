# TAbelhaNix — Secrets management with sops-nix
{
  config,
  lib,
  pkgs,
  sops-nix,
  ...
}:

{
  imports = [ sops-nix.nixosModules.sops ];

  options.tabelhanix.sops = {
    enable = lib.mkEnableOption "sops-nix secrets management";
    ageKeyFile = lib.mkOption {
      type = lib.types.path;
      default = "/persist/secrets/age-key.txt";
      description = "Path to the age key file for decryption";
    };
  };

  config = lib.mkIf config.tabelhanix.sops.enable {
    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      age = {
        keyFile = config.tabelhanix.sops.ageKeyFile;
        sshKeyPaths = [ ];
      };
    };

    environment.variables = {
      SOPS_AGE_KEY_FILE = toString config.tabelhanix.sops.ageKeyFile;
    };
  };
}
