derivation rec{
  name = "simple";
  builder = "/bin/sh";
  args = [ ./simple_builder.sh ];
  buildInputs = [./simple_builder.sh ];
  system = builtins.currentSystem;
}
