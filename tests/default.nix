# TAbelhaNix — NixOS VM tests
{
  pkgs,
  lib,
  niri,
  DankMaterialShell,
  home-manager,
}:

let
  mkEvalTest =
    { name, module }:
    pkgs.testers.nixosTest {
      inherit name;
      nodes.machine = { ... }: {
        imports = [ module ];
        system.stateVersion = "24.11";
        networking.hostName = "tabelhanix";
        fileSystems."/".fsType = "tmpfs";
        fileSystems."/nix".device = "/dev/sda1";
        boot.loader.systemd-boot.enable = true;
      };
      testScript = ''
        machine.start()
        machine.wait_for_unit("multi-user.target")
      '';
    };
in
{
  # Test options module evaluates cleanly
  tabelhanix-options = mkEvalTest {
    name = "tabelhanix-options";
    module = ../modules/options.nix;
  };

  # Live stack boot test (mirrors tabelhanix-iso module stack)
  tabelhanix-live = import ./live.nix {
    inherit
      pkgs
      lib
      niri
      DankMaterialShell
      home-manager
      ;
  };
}
