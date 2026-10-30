{
  users.users.dlabaja = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
  };
  security.sudo.wheelNeedsPassword = false;
}
