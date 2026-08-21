{ config, pkgs, lib, ... }:
{
	programs.claude-code.enable = true;

	home.file = {
		".claude/statusline-command.sh" = {
			source = ./statusline-command.sh;
			executable = true;
			force = true;
		};
		".claude/statusline.py" = {
			source = ./statusline.py;
			force = true;
		};
		".claude/CLAUDE.md" = {
			source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/AGENTS.md";
			force = true;
		};
	};

	home.activation.configureClaudeCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
		if [[ -v DRY_RUN ]]; then
			verboseEcho "Would configure Claude Code"
		else
			claude_dir="${config.home.homeDirectory}/.claude"
			${pkgs.coreutils}/bin/mkdir -p "$claude_dir"

			claude_settings="$claude_dir/settings.json"
			claude_tmp="$claude_settings.home-manager.tmp"
			if [[ -s "$claude_settings" ]]; then
				${pkgs.jq}/bin/jq \
					--arg command "bash ${config.home.homeDirectory}/.claude/statusline-command.sh" \
					'.statusLine = { type: "command", command: $command }' \
					"$claude_settings" > "$claude_tmp"
			else
				${pkgs.jq}/bin/jq -n \
					--arg command "bash ${config.home.homeDirectory}/.claude/statusline-command.sh" \
					'{ statusLine: { type: "command", command: $command } }' > "$claude_tmp"
			fi
			if ! ${pkgs.diffutils}/bin/cmp -s "$claude_settings" "$claude_tmp"; then
				${pkgs.coreutils}/bin/chmod 600 "$claude_tmp"
				${pkgs.coreutils}/bin/mv "$claude_tmp" "$claude_settings"
			else
				${pkgs.coreutils}/bin/rm "$claude_tmp"
			fi
		fi
	'';
}
