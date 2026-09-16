{
  lib,
  osConfig,
  ...
}: {
  imports = lib.optional osConfig.modules.desktop.hyprland.hyprsplit.enable ./hyprsplit.nix;
}
