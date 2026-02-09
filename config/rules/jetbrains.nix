{...}: {
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # "match:class ^(.*jetbrains.*)$, opacity 0.95 0.95"

      # # Fix all dialogs
      # "tag +jb, class:^jetbrains-.+$,floating:1"
      # "stayfocused, tag:jb"
      # "noinitialfocus, tag:jb"
      # "focusonactivate,class:^jetbrains-(?!toolbox)"

      # # Center popups except for context menu
      # "noinitialfocus,class:^jetbrains-(?!toolbox),floating:1"
      # "move 30% 30%,class:^jetbrains-(?!toolbox),title:^(?!win.*),floating:1"
      # "size 40% 40%,class:^jetbrains-(?!toolbox),title:^(?!win.*),floating:1"

      # # Fix tab reordering
      # "noinitialfocus, class:^(.*jetbrains.*)$, title:^\\s$"
      # "nofocus, class:^(.*jetbrains.*)$, title:^\\s$"

      # # Disable mouse focus for floating windows
      # "nofollowmouse, class:^jetbrains-.+$, floating:1"

      # Fix splash screen showing in weird places and prevent annoying focus takeovers
      "tag +jetbrains-splash, class:^jetbrains-.+$, title:^splash$, floating:1"
      "center, tag:jetbrains-splash"
      "nofocus, tag:jetbrains-splash"
      "noborder, tag:jetbrains-splash"

      # Center popups/find windows
      "tag +jetbrains, class:^jetbrains-.+$, title:^$, floating:1"
      "center, tag:jetbrains"
      "stayfocused, tag:jetbrains"
      "noborder, tag:jetbrains"
      "minsize 50% 50%, tag:jetbrains"

      # Disable window flicker when autocomplete or tooltips appear
      "noinitialfocus, class:^jetbrains-.+$, title:^win.+$, floating:1"

      # Disable mouse focus
      "nofollowmouse, class:^jetbrains-.+$"
    ];
  };
}
