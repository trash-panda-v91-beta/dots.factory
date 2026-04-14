{ inputs, lib, ... }:
{
  imports = [ inputs.den.flakeModule ];

  den.hosts.aarch64-darwin.pmb.users.trash-panda-v91-beta = { };

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
}
