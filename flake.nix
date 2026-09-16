{
  description = "Hyprland desktop environment configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # No nixpkgs follows (voids hyprland.cachix.org); rev held before e9e2f64 until quickshell/DMS stop reading workspace ids.
    hyprland-git.url = "github:hyprwm/Hyprland/7ebf13abb3c391604c60c9f627c7a403bcec8d17";

    hyprsplit = {
      url = "github:shezdy/hyprsplit";
      flake = false;
    };

    viicslen-lib = {
      url = "github:viicslen-nix/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
    ];
  in {
    nixosModules.default = import ./default.nix inputs;

    nixosModules.hyprland = self.nixosModules.default;

    checks.x86_64-linux.default = let
      user = "test";
      stateVersion = "26.05";
      # Keep this the rev hosts use: home-manager's Lua renderer differs between commits.
      home-manager = fetchTarball {
        url = "https://github.com/nix-community/home-manager/archive/2c0350c759688177331b8f5242311fae8877bdb3.tar.gz";
        sha256 = "sha256:14lbbilvbjhq7bqbjgvm9mvx0ci2sgg3km8whkpncrwygmvhkp5z";
      };
      testConfig = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.default
          (import "${home-manager}/nixos")
          ({pkgs, ...}: {
            system.stateVersion = stateVersion;
            fileSystems."/" = {
              device = "/dev/null";
              fsType = "ext4";
            };
            boot.loader = {
              grub.enable = false;
              generic-extlinux-compatible.enable = true;
            };

            nixpkgs.config.allowUnfree = true;
            home-manager.useGlobalPkgs = true;

            users.users.${user}.isNormalUser = true;
            home-manager.users.${user}.home.stateVersion = stateVersion;

            modules.desktop.hyprland = {
              enable = true;
              hyprsplit.enable = true;
              terminal = pkgs.hello;
              browser = pkgs.hello;
              editor = pkgs.hello;
              fileManager = pkgs.hello;
              passwordManager = pkgs.hello;
            };
          })
        ];
      };
    in
      # Keep unsafeDiscardOutputDependency: a bare drvPath's deep context makes the check build the whole system.
      nixpkgs.legacyPackages.x86_64-linux.writeText "hyprland-module-eval"
      (builtins.unsafeDiscardOutputDependency testConfig.config.system.build.toplevel.drvPath);

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
