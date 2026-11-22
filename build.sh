#!/bin/sh
set -eu

cd "$(dirname "$0")"

echo Building container
docker build --platform linux/amd64 -t fex-rootfs-fedora:44 -f Containerfile .

echo Archiving container content
docker run --rm fex-rootfs-fedora:44 tar --sort=name --mtime='@0' -czf - -C / --exclude=./proc --exclude=./sys --exclude=./dev . > rootfs.tar.gz

echo Extracting the archive
mkdir ./tmp
tar -xf rootfs.tar.gz -C "./tmp"
rm -f rootfs.tar.gz

echo Removing host-owned files
for f in etc/hosts etc/resolv.conf etc/timezone etc/localtime etc/machine-id \
         etc/passwd etc/passwd- etc/group etc/group- etc/shadow etc/shadow- \
         etc/gshadow etc/gshadow- var/lib/dbus/machine-id; do
  rm -f "./tmp/$f"
done

echo Bundling using erofs
tar -cf - -C ./tmp . | docker run --rm -i --platform linux/amd64 registry.fedoraproject.org/fedora:44 \
  sh -c 'dnf install -y --setopt=tsflags=nodocs erofs-utils >/dev/null && \
         mkdir /rootfs && tar -xf - -C /rootfs && \
         SOURCE_DATE_EPOCH=0 mkfs.erofs --quiet -x-1 -zlz4hc,12 -T0 --all-time /tmp/fex-rootfs.erofs /rootfs && \
         fsck.erofs /tmp/fex-rootfs.erofs && \
         cat /tmp/fex-rootfs.erofs' > fex-rootfs.erofs

echo Cleaning up
rm -rf ./tmp

echo "Built: $PWD/fex-rootfs.erofs"
