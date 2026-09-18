# TAbelhaNix — Live stack VM test
# Boots a minimal VM with niri + DMS, asserts they start
{
  pkgs,
  lib,
  niri,
  DankMaterialShell,
  home-manager,
}:

pkgs.testers.nixosTest {
  name = "tabelhanix-live";

  nodes.machine =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        # Niri compositor
        niri.nixosModules.niri

        # DankMaterialShell
        DankMaterialShell.nixosModules.dank-material-shell

        # Home Manager for the live user (niri settings, etc.)
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.nixos = import ../home/default.nix;
        }
      ];

      system.stateVersion = "24.11";

      boot.loader.systemd-boot.enable = true;

      # Wayland compositor needs virtio-gpu (same pattern as sway.nix test)
      virtualisation.qemu.options = [
        "-vga"
        "none"
        "-device"
        "virtio-gpu-pci"
      ];

      # Live user setup
      users.mutableUsers = true;
      users.users.nixos = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
        ];
        initialHashedPassword = "";
      };
      users.users.root.initialHashedPassword = "";

      # niri package (same as flake override)
      programs.niri.package = pkgs.niri;

      # Allow passwordless sudo
      security.sudo.wheelNeedsPassword = false;

      # Core packages for the live session
      environment.systemPackages = with pkgs; [
        niri
        gitMinimal
        curl
        (writeShellScriptBin "tabelhanix-install" ''
          echo "TAbelhaNix installer placeholder"
        '')
      ];
    };

  testScript =
    { nodes, ... }:
    ''
      machine.start()
      machine.wait_for_unit("multi-user.target")

      # Start niri as the nixos user via login shell (loads /etc/profile → PATH)
      machine.succeed("su - nixos -c 'niri-session &'")
      machine.wait_until_succeeds("pgrep -u nixos -x niri", timeout=30)
      print("niri is running")

      # DMS (dms binary) should be spawned by niri config
      machine.wait_until_succeeds("pgrep -u nixos -x dms", timeout=30)
      print("dms is running")

      # Verify install script exists on PATH
      machine.succeed("command -v tabelhanix-install")

      print("Live stack test passed")
    '';
}
