{ pkgs, lib, ... }:
let
	# Nix has no \u escape, and these glyphs live in the Private Use Area: as bare
	# literals they are unreviewable and silently dropped by tooling that mishandles
	# them, so they are referred to by codepoint. Visible characters - the dot, the
	# sync arrows - stay literal. Grouped under g so ${g.branch} cannot be misread
	# as starship's own $branch.
	glyph = code: builtins.fromJSON "\"\\u${code}\"";
	g = {
		branch = glyph "E0A0";
		clock = glyph "F017";
		elapsed = glyph "F252";
		merge = glyph "E727";
		rebase = glyph "E728";
		cherryPick = glyph "E729";
		revert = glyph "F0E2";
		bisect = glyph "F126";
		zeroWidth = glyph "200B";
	};
in
{
	programs = {
		starship = {
			enable = true;
			presets = [ "nerd-font-symbols" ];

			# IFD: reads starship's own no-runtime-versions preset for the list of
			# modules that report a version, so we never have to maintain it manually.
			# Only the names are reused - the preset's own formats keep the
			# "via"/"with" connectors. nix_shell and docker_context are not in it but
			# get the same icon-only treatment in the toolchain segment
			settings = (lib.genAttrs
				(builtins.attrNames
					(removeAttrs
						(builtins.fromTOML (builtins.readFile
							"${pkgs.starship}/share/starship/presets/no-runtime-versions.toml"))
						[ "$schema" ])
					++ [ "nix_shell" "docker_context" ])
				(_: { format = "[$symbol](overlay0)"; })) // {
				palette = "catppuccin_mocha";

				# Language modules reach the prompt through $all, styled for the pill
				# by the mapAttrs above.
				# Styled after ai/statusline.py: no backgrounds, dim glyph and brighter
				# value, groups three spaces apart, and hue only where something is
				# worth looking at - so the row is grey at rest
				format = "($git_branch$git_commit$git_state$git_status   )($all   )($time)(   $cmd_duration)$line_break$username$hostname$directory$character";

				username = {
					show_always = true;
					format = "[$user]($style)";
					style_user = "bold green";
				};

				hostname = {
					ssh_only = false;
					format = "[@$hostname]($style):";
					style = "bold green";
				};

				directory = {
					truncation_length = 0;
					truncate_to_repo = false;
					style = "bold blue";
				};

				# Pill segments carry their spacing inside the styled span; an unstyled
				# trailing space would punch a hole in the background
				git_branch = {
					format = "[${g.branch} ](overlay0)[$branch](subtext0)";
				};

				git_commit = {
					format = "[ $hash$tag](overlay0)";
				};

				# A glyph per operation rather than the word, so mid-rebase and mid-merge
				# stay distinguishable - they call for different continue commands
				git_state = {
					format = "[ $state( $progress_current/$progress_total)](yellow)";
					merge = g.merge;
					rebase = g.rebase;
					cherry_pick = g.cherryPick;
					revert = g.revert;
					bisect = g.bisect;
					am = g.rebase;
					am_or_rebase = g.rebase;
				};

				# Colour carries the status, not letters: yellow for local changes, red
				# for a conflict, blue for sync direction. Each worktree state is a
				# zero-width symbol, so its variable is non-empty exactly when that state
				# holds - which makes the group render one dot, at a fixed position no
				# matter how many states are set
				git_status = {
					format = "([ ●$modified$staged$untracked$deleted$renamed$stashed$typechanged](yellow))([ ●$conflicted](red))([ $ahead_behind](blue))";
					conflicted = g.zeroWidth;
					untracked = g.zeroWidth;
					modified = g.zeroWidth;
					staged = g.zeroWidth;
					renamed = g.zeroWidth;
					deleted = g.zeroWidth;
					stashed = g.zeroWidth;
					typechanged = g.zeroWidth;
					up_to_date = "";
					ahead = "↑";
					behind = "↓";
					diverged = "↕";
				};

				cmd_duration = {
					format = "[${g.elapsed} ](overlay0)[$duration](subtext0)";
				};

				jobs = {
					format = "[ $symbol$number](overlay0)";
				};

				# On by default and reaches the row through $all, where its "is" prose
				# and 208-bold styling break the grey
				package.disabled = true;

				# Redundant with ai/statusline.py, and on by default, so they would
				# otherwise punch an unstyled hole in the toolchain segment
				claude_context.disabled = true;
				claude_cost.disabled = true;
				claude_model.disabled = true;

				character = {
					# Failure is not signalled by colour here; the exit code segment is off
					error_symbol = "[❯](bold green)";
				};

				time = {
					disabled = false;
					format = "[${g.clock} ](overlay0)[$time](subtext0)";
				};

				# Catppuccin Mocha, verbatim from catppuccin/starship
				palettes.catppuccin_mocha = {
					rosewater = "#f5e0dc";
					flamingo = "#f2cdcd";
					pink = "#f5c2e7";
					mauve = "#cba6f7";
					red = "#f38ba8";
					maroon = "#eba0ac";
					peach = "#fab387";
					yellow = "#f9e2af";
					green = "#a6e3a1";
					teal = "#94e2d5";
					sky = "#89dceb";
					sapphire = "#74c7ec";
					blue = "#89b4fa";
					lavender = "#b4befe";
					text = "#cdd6f4";
					subtext1 = "#bac2de";
					subtext0 = "#a6adc8";
					overlay2 = "#9399b2";
					overlay1 = "#7f849c";
					overlay0 = "#6c7086";
					surface2 = "#585b70";
					surface1 = "#45475a";
					surface0 = "#313244";
					base = "#1e1e2e";
					mantle = "#181825";
					crust = "#11111b";
				};
			};
		};
	};
}
