{
  delib,
  host,
  ...
}:
delib.module {
  name = "features.kubernetes";

  options = delib.singleEnableOption host.kubernetesFeatured;
}
