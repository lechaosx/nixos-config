{ config, lib, ... }:
{
	options.grub = {
		gfxmodeEfi = lib.mkOption {
			type = lib.types.str;
		};
		configurationLimit = lib.mkOption {
			type = lib.types.int;
			default = 10;
		};
	};

	config.boot.loader = {
		grub = {
			enable = true;
			efiSupport = true;
			device = "nodev";
			gfxmodeEfi = config.grub.gfxmodeEfi;
			configurationLimit = config.grub.configurationLimit;
		};

		efi.canTouchEfiVariables = true;
	};
}
