# Evaluate the module against a minimal test system, and check formatting and statix lints.
check:
	nix flake check --print-build-logs
