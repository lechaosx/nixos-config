{ pkgs, lib, ... }:
{
	programs = {
		starship = {
			enable = true;
			enableTransience = true;
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
				(_: { format = "[$symbol]($style)"; style = "fg:crust bg:yellow"; })) // {
				add_newline = false;
				palette = "catppuccin_mocha";

				# Language modules reach the prompt through $all, styled for the pill
				# by the mapAttrs above.
				# One continuous pill led by $time, which always renders, so the
				# round ends always meet real content. Segments cannot collapse: every
				#  transition hard-codes fg:previous and bg:next, so an absent middle
				# segment thins to a sliver of its two transitions.
				# $cmd_duration sits after the closing cap, outside the pill
				# The leading $line_break is what add_newline would do, but
				# add_newline also applies to profile renders, which would put a
				# blank line above every transient prompt in the scrollback.
				format = "$line_break[](fg:red)$time[ ](bg:red)[](fg:red bg:peach)$git_branch$git_commit$git_state$git_status[ ](bg:peach)[](fg:peach bg:yellow)[ ](bg:yellow)$all$jobs[](fg:yellow)$cmd_duration$line_break$username$hostname$directory$character";

				# Rendered by starship_transient_prompt_func once a command is submitted.
				# The leading break is what separates entries in the scrollback
				profiles.transient = "$line_break$username$hostname$directory$character";

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
					format = "[ $symbol$branch]($style)";
					symbol = " ";
					style = "fg:crust bg:peach";
				};

				git_commit = {
					format = "[ $hash$tag]($style)";
					style = "fg:crust bg:peach";
				};

				git_state = {
					format = "[ $state( $progress_current/$progress_total)]($style)";
					style = "fg:crust bg:peach";
				};

				git_status = {
					format = "([ \\[$all_status$ahead_behind\\]]($style))";
					style = "fg:crust bg:peach";
				};

				cmd_duration = {
					min_time = 0;
					show_milliseconds = true;
					format = "[   $duration]($style)";
					style = "green";
				};

				jobs = {
					format = "[ $symbol$number]($style)";
					style = "fg:crust bg:yellow";
				};

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
					format = "[  $time]($style)";
					style = "fg:crust bg:red";
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

		fish = {
			functions.starship_transient_prompt_func = ''
				starship prompt --profile transient $argv
			'';
		};
	};
}
