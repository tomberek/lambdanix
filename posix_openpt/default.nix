{stdenv}:
stdenv.mkDerivation {
  pname = "posix_openpt";
  version = "0.0.1";
  src = ./.;
  installFlags = [ "PREFIX=$(out)" ];
}
