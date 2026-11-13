FROM --platform=linux/amd64 registry.fedoraproject.org/fedora:45

# package list mirrors upstream FEX-Emu/RootFS
RUN dnf install -y --setopt=install_weak_deps=0 --setopt=tsflags=nodocs \
      nss nss-util nss-softokn nss-softokn-freebl nspr \
      gtk3 atk at-spi2-core at-spi2-atk cairo cairo-gobject pango glib2 \
      gdk-pixbuf2 librsvg2 glycin-libs glycin-loaders libcloudproviders \
      libtinysparql libsecret libnotify libappindicator-gtk3 \
      libX11 libX11-xcb libxcb libXau libXcomposite libXdamage libXext libXfixes \
      libXi libXrandr libXrender libXtst libXcursor libXinerama libXxf86vm \
      libxkbcommon libxkbcommon-x11 libxshmfence xcb-util xcb-util-image \
      xcb-util-keysyms xcb-util-renderutil xcb-util-wm xcb-util-cursor xcb-util-xrm \
      libwayland-client libwayland-server libwayland-cursor libwayland-egl \
      xkeyboard-config \
      mesa-libGL mesa-libEGL mesa-libgbm mesa-libGLU mesa-demos mesa-dri-drivers mesa-va-drivers \
      mesa-vulkan-drivers vulkan-loader egl-wayland \
      libglvnd libglvnd-glx libglvnd-egl libglvnd-opengl libglvnd-gles \
      libdrm libva libvdpau pixman llvm-libs spirv-llvm-translator \
      libunwind libnsl libpciaccess pciutils usbutils fuse-libs fuse3-libs \
      ibus-libs mangohud sdl12-compat glew-devel \
      xdg-desktop-portal xdg-desktop-portal-gtk openssl-libs \
      protobuf-c protobuf-compiler pkgconf gobject-introspection \
      python3 curl xterm zenity xz clinfo vulkan-tools \
      alsa-lib pulseaudio pulseaudio-libs alsa-plugins-pulseaudio libasyncns \
      libsndfile libvorbis libogg flac-libs opus speex openal-soft \
      libcanberra SDL2 SDL3 dbus-libs dbus-glib avahi-libs \
      cups-libs libjpeg-turbo libtiff libwebp libpng freetype fontconfig \
      harfbuzz fribidi libthai graphite2 libdatrie expat libffi zlib zstd \
      lz4 brotli libselinux libsepol libmount libblkid \
      libcap libcap-ng libattr libacl pcre2 pcre2-utf16 pcre2-utf32 \
      libunistring libidn2 libpsl publicsuffix-list-dafsa json-glib \
      sqlite-libs geocode-glib geoclue2-libs libgsf shared-mime-info \
      desktop-file-utils hicolor-icon-theme adwaita-icon-theme libseccomp \
    && dnf clean all

RUN dnf install -y --setopt=install_weak_deps=0 --setopt=tsflags=nodocs \
      glibc.i686 libX11.i686 libX11-xcb.i686 libxcb.i686 xcb-util.i686 xcb-util-cursor.i686 xcb-util-image.i686 \
      xcb-util-keysyms.i686 xcb-util-xrm.i686 libXext.i686 libXdamage.i686 libXrandr.i686 libXxf86vm.i686 \
      libxkbcommon.i686 libxshmfence.i686 libwayland-client.i686 libwayland-egl.i686 \
      alsa-lib.i686 pulseaudio-libs.i686 \
      nss.i686 nspr.i686 mesa-libGL.i686 mesa-libEGL.i686 mesa-libgbm.i686 mesa-libGLU.i686 mesa-dri-drivers.i686 \
      mesa-vulkan-drivers.i686 libdrm.i686 libglvnd.i686 libglvnd-egl.i686 \
      libglvnd-opengl.i686 libglvnd-gles.i686 vulkan-loader.i686 zlib-ng-compat.i686 libstdc++.i686 \
      libvorbis.i686 flac-libs.i686 speex.i686 openal-soft.i686 SDL3.i686 sdl12-compat.i686 \
      libvdpau.i686 libunwind.i686 libnsl.i686 llvm-libs.i686 spirv-llvm-translator.i686 mangohud.i686 \
      openssl-libs.i686 fuse-libs.i686 fuse3-libs.i686 ibus-libs.i686 harfbuzz.i686 \
      protobuf3-c.i686 protobuf-compiler.i686 pkgconf.i686 python3.i686 systemd.i686 \
      xdg-desktop-portal.i686 \
    && dnf clean all

# generate ld cache
RUN /usr/sbin/ldconfig

# shrink the final image: no debuginfo, no docs
RUN dnf remove -y '*-debuginfo' '*-debugsource' 2>/dev/null || true; \
    find /usr/lib64 /usr/lib /usr/bin /usr/sbin -type f \( -name '*.so*' -o -perm -u+x \) -exec strip --strip-debug {} + 2>/dev/null || true; \
    rm -rf /usr/share/doc/* /usr/share/man/* /usr/share/locale/*/LC_MESSAGES 2>/dev/null || true; \
    dnf clean all
