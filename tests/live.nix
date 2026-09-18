# TAbelhaNix — Live stack VM test
# Boots a minimal VM with niri + DMS, asserts they start via autologin
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

      # Minimal filesystem
      fileSystems."/".fsType = "tmpfs";
      fileSystems."/nix".device = "/dev/vda";

      boot.loader.systemd-boot.enable = true;

      # Wayland compositor needs virtio-gpu (same pattern as sway.nix test)
      virtualisation.qemu.options = [
        "-vga"
        "none"
        "-device"
        "virtio-gpu-pci"
      ];

      # Live user setup (mirrors installation-device.nix profile)
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

      # Autologin
      services.getty.autologinUser = "nixos";

      # niri package (same as flake override)
      programs.niri.package = pkgs.niri;

      # Start niri on login for the autologin user
      programs.bash.loginShellInit = ''
        if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
          exec niri-session
        fi
      '';

      # Allow passwordless sudo
      security.sudo.wheelNeedsPassword = false;

      # Core packages for the live session
      environment.systemPackages = with pkgs; [
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

      # Wait for autologin and niri-session to launch
      machine.wait_until_succeeds("pgrep -u nixos -x niri", timeout=30)
      print("niri is running")

      # DMS (dms binary) should be spawned by niri
      machine.wait_until_succeeds("pgrep -u nixos -x dms", timeout=30)
      print("dms is running")

      # Verify install script exists on PATH
      machine.succeed("command -v tabelhanix-install")

      print("Live stack test passed")
    '';
}
