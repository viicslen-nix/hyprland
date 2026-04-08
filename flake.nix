{
  description = "Hyprland desktop environment configuration flake";

  inputs = {
    # Base system packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    viicslen-lib = {
      url = "github:viicslen-nix/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland compositor and ecosystem
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    # Hyprland utilities and extensions
    pyprland.url = "github:hyprland-community/pyprland";
    pyprland.inputs.nixpkgs.follows = "nixpkgs";

    # Additional tools and contributions
    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprland-contrib.inputs.nixpkgs.follows = "nixpkgs";

    # Compositor plugins
    hyprland-plugins.url = "github:hyprwm/hyprland-plugins";
    hyprland-plugins.inputs.nixpkgs.follows = "nixpkgs";

    # Alternative panel
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    hyprpanel.inputs.nixpkgs.follows = "nixpkgs";

    # Session management
    hypridle.url = "github:hyprwm/hypridle";
    hypridle.inputs.nixpkgs.follows = "nixpkgs";

    # Wallpaper management
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprpaper.inputs.nixpkgs.follows = "nixpkgs";

    # Workspace management
    hyprspace.url = "github:KZDKM/Hyprspace";
    hyprspace.inputs.hyprland.follows = "hyprland";

    # Window splitting utilities
    hyprsplit.url = "github:shezdy/hyprsplit/v0.54.3";
    hyprsplit.inputs.hyprland.follows = "hyprland";

    # Color management
    hyprchroma.url = "github:alexhulbert/Hyprchroma";
    hyprchroma.inputs.hyprland.follows = "hyprland";

    # Noctalia shell
    noctalia.url = "github:noctalia-dev/noctalia-shell";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {nixpkgs, ...} @ inputs: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
    ];
  in {
    # Main NixOS module for hyprland desktop environment
    nixosModules.default = import ./default.nix inputs;

    # Formatter for `nix fmt`
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
