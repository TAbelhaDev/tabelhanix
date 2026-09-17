# TAbelhaNix — NixOS VM tests
# These tests only validate that modules evaluate cleanly (no build needed)
{ pkgs, lib }:

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
}
