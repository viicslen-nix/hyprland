{
  description = "Hyprland desktop environment configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
      # release-26.05; a branch tarball's hash goes stale on the next backport, so pin the commit.
      home-manager = fetchTarball {
        url = "https://github.com/nix-community/home-manager/archive/ec172013fa62135f58fb58dd17ae9651e8f39727.tar.gz";
        sha256 = "sha256:02mrnlirg3jxqfgkv3jh8ar9hqiwhwqq9m7n5jv5hq40vjzq2s1d";
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
              hyprsplit.enable = false;
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
