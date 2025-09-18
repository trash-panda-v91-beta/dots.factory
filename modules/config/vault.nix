{ delib, inputs, ... }:
delib.module {
  name = "vault";

  myconfig.always.args.shared.vault = inputs.vault;

}
