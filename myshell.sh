#!/bin/sh
set -euo pipefail

mkdir -p /tmp/{dev/pts,nix,tmp,var,bin,usr/bin}
cd /tmp
touch /tmp/dev/null

cat /tmp/out.nar.base64 | tr -d '"' | base64 -d > /tmp/out.nar
head /tmp/out.nar >&2

export SSL_CERT_FILE=$(find /var/task/*/etc/ssl/certs/ca-bundle.crt | head -n1)
export POSIX_OPENPT=$(find /var/task/*/posix_openpt.so | head -n1)
export LIBFAKECHROOT=$(find /var/task/*/lib/fakechroot/libfakechroot.so | head -n1)
export CHROOT=$(find /var/task/*/bin/chroot | head -n1)
export HOME=/tmp
export FAKECHROOT_EXCLUDE_PATH=/proc:/sys:/var/task

PATH2=
LD_LIBRARY_PATH2=
for d in /var/task/*/ ; do
    PATH2="${d}bin${PATH2:+:}$PATH2"
    LD_LIBRARY_PATH2="${d}lib${LD_LIBRARY_PATH2:+:}$LD_LIBRARY_PATH2"
done
LD_PRELOAD2=$LIBFAKECHROOT:$POSIX_OPENPT
ln -sf /var/task/*/bin/bash /tmp/bin/sh
ln -sf /var/task/*/bin/env /tmp/usr/bin/env

{ PATH=$PATH2 LD_LIBRARY_PATH=$LD_LIBRARY_PATH2 LD_PRELOAD=$LD_PRELOAD2 \
$CHROOT /tmp nix-store --import < /tmp/out.nar ; } \
| tail -n1 > /tmp/out.drv

echo imported: $(cat /tmp/out.drv) >&2

PATH=$PATH2 LD_LIBRARY_PATH=$LD_LIBRARY_PATH2 LD_PRELOAD=$LD_PRELOAD2 \
$CHROOT /tmp nix-store -r $(cat /tmp/out.drv) --option sandbox false
