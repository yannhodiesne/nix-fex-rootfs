#!/bin/sh
set -eu

cd "$(dirname "$0")"

docker build --platform linux/amd64 -t fex-rootfs-fedora:44 -f Containerfile .
docker run --rm -v "$PWD":/out fex-rootfs-fedora:44 tar --sort=name --mtime='@0' -czf /out/rootfs.tar.gz -C / --exclude=./out --exclude=./proc --exclude=./sys --exclude=./dev .

mkdir ./tmp
tar -xf rootfs.tar.gz -C "./tmp"

printf 'nameserver 8.8.8.8\nnameserver 1.1.1.1\n' > ./tmp/etc/resolv.conf
printf '127.0.0.1 localhost\n::1 localhost\n' > ./tmp/etc/hosts

docker run --rm -v "./tmp":/rootfs -v "$PWD":/out --platform linux/amd64 registry.fedoraproject.org/fedora:44 \
  sh -c 'dnf install -y --setopt=tsflags=nodocs erofs-utils >/dev/null && \
         SOURCE_DATE_EPOCH=0 mkfs.erofs --quiet -x-1 -zlz4hc,12 -T0 --all-time /out/fex-rootfs.erofs /rootfs && \
         fsck.erofs /out/fex-rootfs.erofs'

echo "built: $PWD/fex-rootfs.erofs"
