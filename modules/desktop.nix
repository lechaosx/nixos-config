{ pkgs, ... }:
let
	# alsa-lib resolves iec958:CARD=x to device 0 (the analog endpoint) for any USB card
	# missing from its iec958_device quirk table, so PipeWire's profile probe succeeds and
	# every USB headset gains a phantom S/PDIF output. Invert the fallback to a device
	# number that cannot open, matching what upstream already does for iec958_2.
	# https://github.com/alsa-project/alsa-lib/issues/292
	alsaConfigDir = pkgs.runCommand "alsa-config-no-phantom-iec958" { } ''
		cp -r --no-preserve=mode ${pkgs.alsa-lib}/share/alsa $out

		matches=$(grep -cE '^[[:space:]]+default 0$' $out/cards/USB-Audio.conf)
		if [ "$matches" != 1 ]; then
			echo "expected exactly one iec958 fallback, found $matches" >&2
			exit 1
		fi

		sed -i -E 's/^([[:space:]]+)default 0$/\1default 999/' $out/cards/USB-Audio.conf
	'';
in
{
	services = {
		xserver = {
			enable = true;
			excludePackages = [ pkgs.xterm ];
		};

		displayManager.gdm.enable = true;
		desktopManager.gnome.enable = true;

		pipewire = {
			enable = true;
			alsa = {
				enable = true;
				support32Bit = true;
			};
			pulse.enable = true;
		};
	};

	security.rtkit.enable = true;

	# WirePlumber probes card profiles as a user unit, before any shell profile is
	# sourced, so the variable has to come from the user manager itself.
	systemd.user.settings.Manager.DefaultEnvironment = "ALSA_CONFIG_DIR=${alsaConfigDir}";

	environment.gnome.excludePackages = [
		pkgs.gnome-tour
		pkgs.baobab
		pkgs.epiphany
		pkgs.gnome-calendar
		pkgs.gnome-characters
		pkgs.gnome-clocks
		pkgs.gnome-connections
		pkgs.gnome-contacts
		pkgs.gnome-font-viewer
		pkgs.gnome-maps
		pkgs.gnome-music
		pkgs.gnome-weather
		pkgs.simple-scan
		pkgs.totem
		pkgs.yelp
		pkgs.file-roller
		pkgs.geary
		pkgs.seahorse
		pkgs.sushi
	];

}
