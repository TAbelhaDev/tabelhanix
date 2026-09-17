{
  description = "TAbelhaNix — NixOS flake installer for the niri + DankMaterialShell stack";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Niri compositor
    niri.url = "github:sodiboo/niri-flake";

    # DankMaterialShell
    DankMaterialShell.url = "github:AvengeMedia/DankMaterialShell";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Impermanence
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs =
    {
      self,
      nixpkgs,
      niri,
      DankMaterialShell,
      home-manager,
      sops-nix,
      impermanence,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: nixpkgs.legacyPackages.${system});

      # Helper to create a NixOS configuration
      mkNixosConfig =
        {
          system ? "x86_64-linux",
          modules ? [ ],
          profile ? { },
          homeConfig ? ./home/default.nix,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit sops-nix impermanence; };
          modules = [
            ./modules/nixos.nix
            niri.nixosModules.niri
            DankMaterialShell.nixosModules.dank-material-shell
            ./modules/dms.nix
            ./modules/nvidia.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.tabelha = import homeConfig;
            }
            # Basic root filesystem for configurations without impermanence
            {
              fileSystems."/" = {
                device = "/dev/disk/by-label/nixos";
                fsType = "ext4";
              };
            }
            # Override niri package to use nixpkgs version (niri-flake has libdisplay-info_0_2 issue)
            ({ pkgs, ... }: {
              programs.niri.package = pkgs.niri;
            })
          ]
          ++ modules
          ++ [ profile ];
        };

      # Default options for all configurations
      defaultOptions = {
        tabelhanix = {
          gpu = "none";
          laptop = false;
          gaming = false;
          dev = false;
          bluetooth = false;
          vm = false;
          flatpak = false;
          postgresql = false;
          redis = false;
          sops.enable = false;
        };
      };
    in
    {
      nixosConfigurations = {
        # Default configuration
        tabelhanix = mkNixosConfig {
          profile = defaultOptions;
        };

        # Configuration with NVIDIA support
        tabelhanix-nvidia = mkNixosConfig {
          profile = {
            tabelhanix = {
              gpu = "nvidia";
              laptop = true;
              gaming = true;
              dev = true;
              bluetooth = true;
              vm = true;
              flatpak = true;
              postgresql = false;
              redis = false;
              sops.enable = false;
            };
          };
        };

        # Minimal configuration
        tabelhanix-minimal = mkNixosConfig {
          homeConfig = ./home/minimal.nix;
          profile = {
            tabelhanix = {
              gpu = "none";
              laptop = false;
              gaming = false;
              dev = false;
              bluetooth = false;
              vm = false;
              flatpak = false;
              postgresql = false;
              redis = false;
              sops.enable = false;
            };
          };
        };

        # Laptop configuration
        tabelhanix-laptop = mkNixosConfig {
          modules = [
            ./modules/hardware/laptop.nix
          ];
          profile = {
            tabelhanix = {
              gpu = "none";
              laptop = true;
              gaming = false;
              dev = false;
              bluetooth = true;
              vm = false;
              flatpak = false;
              postgresql = false;
              redis = false;
              sops.enable = false;
            };
          };
        };

        # Desktop with Intel GPU
        tabelhanix-intel = mkNixosConfig {
          modules = [
            ./modules/hardware/intel.nix
          ];
          profile = {
            tabelhanix = {
              gpu = "intel";
              laptop = false;
              gaming = false;
              dev = false;
              bluetooth = false;
              vm = false;
              flatpak = false;
              postgresql = false;
              redis = false;
              sops.enable = false;
            };
          };
        };

        # Desktop with AMD GPU
        tabelhanix-amd = mkNixosConfig {
          modules = [
            ./modules/hardware/amd.nix
          ];
          profile = {
            tabelhanix = {
              gpu = "amd";
              laptop = false;
              gaming = false;
              dev = false;
              bluetooth = false;
              vm = false;
              flatpak = false;
              postgresql = false;
              redis = false;
              sops.enable = false;
            };
          };
        };

        # Live ISO — bootable USB with full TAbelhaNix stack
        tabelhanix-iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit sops-nix impermanence; };
          modules = [
            # NixOS installer base (minimal with autologin)
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

            # Core TAbelhaNix modules
            ./modules/nixos.nix
            niri.nixosModules.niri
            DankMaterialShell.nixosModules.dank-material-shell
            ./modules/dms.nix
            ./modules/nvidia.nix

            # Home Manager for live user
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nixos = import ./home/default.nix;
            }

            # Override niri package to use nixpkgs version
            ({ pkgs, ... }: {
              programs.niri.package = pkgs.niri;
            })

            # Live ISO specifics
            ({ pkgs, lib, ... }: {
              # Autologin on tty1 → niri-session
              systemd.services."autologin@tty1" = {
                wantedBy = [ "multi-user.target" ];
                after = [ "systemd-user-sessions.service" ];
                serviceConfig = {
                  ExecStart = [
                    ""
                    "@${pkgs.util-linux}/bin/agetty --autologin nixos --noclear %I $TERM"
                  ];
                  Type = "idle";
                };
              };

              programs.bash.loginShellInit = ''
                if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
                  exec niri-session
                fi
              '';

              # Clone repo + install script on PATH
              environment.systemPackages = with pkgs; [
                gitMinimal
                (writeShellScriptBin "tabelhanix-install" ''
                  echo "Cloning TAbelhaNix..."
                  git clone https://github.com/TAbelhaDev/tabelhanix.git /home/nixos/tabelhanix
                  cd /home/nixos/tabelhanix
                  bash scripts/install.sh
                '')
              ];

              # Allow passwordless sudo for install
              security.sudo.wheelNeedsPassword = false;

              # Ensure nix has flakes enabled
              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
            })
          ];
        };
      };

      # Development shell
      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.mkShell {
          buildInputs = with nixpkgsFor.${system}; [
            nixfmt-rfc-style
            nil
            nixpkgs-fmt
            nix-index
            nix-prefetch-github
          ];
        };
      });

      # Formatter
      formatter = forAllSystems (system: nixpkgsFor.${system}.nixfmt-rfc-style);

      # Packages
      packages = forAllSystems (system: {
        default = nixpkgsFor.${system}.emptyDirectory;
      });

      # Checks
      checks = nixpkgs.lib.genAttrs supportedSystems (
        system:
        nixpkgs.lib.optionalAttrs (system == "x86_64-linux") (
          import ./tests {
            pkgs = nixpkgsFor.${system};
            lib = nixpkgs.lib;
          }
        )
      );

      # Overlays
      overlays.default = final: prev: {
        # Custom overlay if needed
      };
    };
}
