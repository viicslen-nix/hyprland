# Check that the hyprland module evaluates correctly against a minimal test configuration.
check:
	nix flake check --print-build-logs
