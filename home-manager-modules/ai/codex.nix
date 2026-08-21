{ config, pkgs, lib, ... }:
{
	programs.codex.enable = true;

	home.file.".codex/AGENTS.md" = {
		source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/AGENTS.md";
		force = true;
	};

	home.activation.configureCodex = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
		if [[ -v DRY_RUN ]]; then
			verboseEcho "Would configure Codex"
		else
			codex_dir="${config.home.homeDirectory}/.codex"
			${pkgs.coreutils}/bin/mkdir -p "$codex_dir"

			codex_config="$codex_dir/config.toml"
			codex_tmp="$codex_config.home-manager.tmp"
			${pkgs.bash}/bin/bash ${./configure-codex.sh} "$codex_config" "$codex_tmp"
			if ! ${pkgs.diffutils}/bin/cmp -s "$codex_config" "$codex_tmp"; then
				${pkgs.coreutils}/bin/chmod 600 "$codex_tmp"
				${pkgs.coreutils}/bin/mv "$codex_tmp" "$codex_config"
			else
				${pkgs.coreutils}/bin/rm "$codex_tmp"
			fi
		fi
	'';
}
