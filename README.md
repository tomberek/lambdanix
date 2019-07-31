# Nix powered lambda
Uses several hacks to get Nix working in AWS Lambda.

## The story
- containers
- chroot
- fakeroot
- udocker
- LD_PRELOAD
- namespaces
- nix rewriting
- nix patching
- early kill of builder
- nix configuration
- nix bundling
- ptmx,pty horror


## Usage

TL;DR
```
make bundle
make update
make invoke
```

What is happening?

1) Produce the Package. This involves a patched Nix (https://github.com/NixOS/nix/issues/2176) and including several additional libraries like certs, fakechroot. Then rewrite all the paths (https://github.com/timjrd/nixrewrite).
2) Upload to AWS. Must have a `.arn` containing the arn for a role with permissions for your lambda funcion.
3) Create a serialized description of the inputs and steps to take, out.nar.
4) Invoke the Lambda with the NAR, and obtain a build.
5) Add additional commands to move the build to a cache (like `nix copy`, it works with s3).
6) ???
7) Profit
