FROM --platform=linux/amd64 registry.fedoraproject.org/fedora:44

RUN dnf upgrade -y --setopt=install_weak_deps=0 --setopt=tsflags=nodocs && dnf clean all

# package list mirrors upstream FEX-Emu/RootFS
RUN dnf install -y --setopt=install_weak_deps=0 --setopt=tsflags=nodocs \
      SDL3 flac-libs fuse-libs fuse3-libs glew-devel glibc harfbuzz ibus-libs libX11-xcb \
      libXdamage libXext libXrandr libXxf86vm libglvnd-egl libglvnd-gles libglvnd-opengl libnsl \
      libpciaccess libunwind libvdpau libvorbis libwayland-client libwayland-egl libxkbcommon \
      libxshmfence llvm-libs mangohud mesa-demos mesa-dri-drivers mesa-libEGL mesa-libGL \
      mesa-libGLU mesa-vulkan-drivers nspr nss openal-soft openssl-libs pkgconf protobuf-c \
      protobuf-compiler pulseaudio python3 sdl12-compat speex spirv-llvm-translator systemd \
      xcb-util xcb-util-cursor xcb-util-image xcb-util-keysyms xcb-util-xrm xdg-desktop-portal \
      clinfo curl dbus dnf-utils gobject-introspection pciutils rsync sudo usbutils \
      util-linux-core vulkan-tools xdg-desktop-portal-gtk xterm xz zenity \
      nss-util nss-softokn nss-softokn-freebl ca-certificates tzdata \
    && dnf clean all

RUN dnf install -y --setopt=install_weak_deps=0 --setopt=tsflags=nodocs \
      SDL3.i686 flac-libs.i686 fuse-libs.i686 fuse3-libs.i686 glew-devel.i686 glibc.i686 \
      harfbuzz.i686 ibus-libs.i686 libX11-xcb.i686 libXdamage.i686 libXext.i686 libXrandr.i686 \
      libXxf86vm.i686 libglvnd-egl.i686 libglvnd-gles.i686 libglvnd-opengl.i686 libnsl.i686 \
      libunwind.i686 libvdpau.i686 libvorbis.i686 libwayland-client.i686 libwayland-egl.i686 \
      libxkbcommon.i686 libxshmfence.i686 llvm-libs.i686 mangohud.i686 mesa-dri-drivers.i686 \
      mesa-libEGL.i686 mesa-libGL.i686 mesa-libGLU.i686 mesa-vulkan-drivers.i686 nspr.i686 \
      nss.i686 openal-soft.i686 openssl-libs.i686 pkgconf.i686 protobuf-c.i686 \
      protobuf-compiler.i686 python3.i686 sdl12-compat.i686 speex.i686 spirv-llvm-translator.i686 \
      systemd.i686 xcb-util-cursor.i686 xcb-util-image.i686 xcb-util-keysyms.i686 \
      xcb-util-xrm.i686 xcb-util.i686 xdg-desktop-portal.i686 \
      nss-util.i686 nss-softokn.i686 nss-softokn-freebl.i686 ca-certificates tzdata \
    && dnf clean all

# resolv.conf and hosts must be baked in
RUN printf 'nameserver 8.8.8.8\nnameserver 1.1.1.1\n' > /etc/resolv.conf \
 && printf '127.0.0.1 localhost\n::1 localhost\n' > /etc/hosts

# guest Mesa provider manifest read by Steam's FEX compatibility tool
COPY rootfs-overlay/graphics_provider.json /graphics_provider.json

# generate ld cache
RUN /usr/sbin/ldconfig

# shrink the final image: no debuginfo, no docs
RUN dnf remove -y '*-debuginfo' '*-debugsource' 2>/dev/null || true; \
    find /usr/lib64 /usr/lib /usr/bin /usr/sbin -type f \( -name '*.so*' -o -perm -u+x \) -exec strip --strip-debug {} + 2>/dev/null || true; \
    rm -rf /usr/share/doc/* /usr/share/man/* /usr/share/locale/*/LC_MESSAGES 2>/dev/null || true; \
    dnf clean all

# strip setuid/setgid bits like upstream
RUN find /usr/bin /usr/sbin /bin /sbin -type f -perm /6000 -exec chmod a-s {} + 2>/dev/null || true
