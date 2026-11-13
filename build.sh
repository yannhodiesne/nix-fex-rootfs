#!/bin/sh
set -eu

cd "$(dirname "$0")"

docker build --platform linux/amd64 -t fex-rootfs-fedora:45 -f Containerfile .
docker run --rm -v "$PWD":/out fex-rootfs-fedora:45 tar --sort=name --mtime='@0' -czf /out/rootfs.tar.gz -C / --exclude=./out --exclude=./proc --exclude=./sys --exclude=./dev .

mkdir ./tmp
tar -xf rootfs.tar.gz -C "./tmp"
docker run --rm -v "./tmp":/rootfs -v "$PWD":/out --platform linux/amd64 registry.fedoraproject.org/fedora:45 \
  sh -c 'dnf install -y --setopt=tsflags=nodocs erofs-utils >/dev/null && \
         SOURCE_DATE_EPOCH=0 mkfs.erofs --quiet -x-1 -zlz4hc,12 -T0 --all-time /out/fex-rootfs.erofs /rootfs && \
         fsck.erofs /out/fex-rootfs.erofs'
echo "built: $PWD/fex-rootfs.erofs"
