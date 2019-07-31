{stdenv,cpio,...}:
stdenv.mkDerivation {
  pname = "nixrewrite";
  version = "0.0.1";
  src = builtins.fetchGit {
    url = "https://github.com/timjrd/nixrewrite";
    rev = "aca6171db27dd09df90b6eab6618ff2f3e1acd92";
    ref = "master";
  };
  propagatedBuildInputs = [ cpio ];
  installPhase = ''
    mkdir -p $out/bin
    cp -t $out/bin nixrewrite
  '';
}
