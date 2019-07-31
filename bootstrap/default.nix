{pkgs, ...}:
pkgs.buildGoPackage rec {
  name = "bootstrap-${version}";
  version = "0.0.1";
  goPackagePath = "github.com/tomberek/bootstrap";
  src = ./.;
  preBuild = ''
    export CGO_ENABLED=0;
    export GOOS="linux";
    export GOARCH="amd64";
  '';
  subPackages = [ "." ];

}
