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

      # Packages (for future use)
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
