{
  users.users.github = {
    isNormalUser = true;
    linger = true;
    openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
  };
}
