{ config, lib, ... }:
{
	options.grub.gfxmodeEfi = lib.mkOption {
		type = lib.types.str;
	};

	config.boot.loader = {
		grub = {
			enable = true;
			efiSupport = true;
			device = "nodev";
			gfxmodeEfi = config.grub.gfxmodeEfi;
			configurationLimit = 10;
		};

		efi.canTouchEfiVariables = true;
	};
}
