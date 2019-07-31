{runCommand ,cacert,
nixrewrite,
go-bootstrap,
posix_openpt,
fakechroot,
pkgs,
...}:
let
  newnix = pkgs.nixUnstable.overrideAttrs ( old:{
    prePatch=''
      substituteInPlace configure.ac --replace posix_fallocate strsignal
      substituteInPlace src/libutil/util.cc --replace options.dieWithParent 0
    '';
    doCheck=false;
    doInstallCheck=false;
    patches=[./patch.diff];
  });
in

runCommand "vartasknix-0.0.1" ({
  buildInputs = [newnix nixrewrite];
  exportReferencesGraph = [ "foo" newnix ];
  }) ''
    echo $out
    mkdir $out
    cp ${./myshell.sh} $out/myshell.sh
    cd $out
    cat /build/foo | sort | uniq | awk '/\/nix/' | xargs -L1 basename > hashes
    echo ${cacert} | xargs -L1 basename >> hashes
    echo ${posix_openpt} | xargs -L1 basename >> hashes
    echo ${fakechroot} | xargs -L1 basename >> hashes
    ( cd /nix/store && find $(cat $out/hashes) -depth -print | cpio -o ) > nix.cpio
    nixrewrite /nix/store /var/task/ hashes < nix.cpio | cpio -id
    rm nix.cpio hashes
    cp ${go-bootstrap}/bin/bootstrap $out
    mkdir -p $out/.config/nix
    echo "sandbox=false" >> $out/.config/nix/nix.conf
  ''



