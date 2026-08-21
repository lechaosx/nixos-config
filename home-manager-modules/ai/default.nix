{ ... }:
{
	imports = [
		./claude-code.nix
		./codex.nix
	];

	home.file."AGENTS.md" = {
		source = ./AGENTS.md;
		force = true;
	};
}
