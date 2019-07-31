let
  pkgs = import <nixpkgs>{};
  go-bootstrap = pkgs.callPackage ./bootstrap {};
  posix_openpt = pkgs.callPackage ./posix_openpt {};
  nixrewrite = pkgs.callPackage ./nixrewrite.nix {};
  vartasknix = pkgs.callPackage ./vartasknix.nix {inherit nixrewrite go-bootstrap posix_openpt;};
  lambda-package = pkgs.runCommand "function.zip" {
    buildInputs = [pkgs.zip];
  } ''
    cd ${vartasknix}
    zip --symlinks -r $out *
  '';
in
  #vartasknix
  lambda-package
