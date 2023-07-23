# KeePassXC Linux CI Build Dockerfile
# Copyright (C) 2017-2022 KeePassXC team <https://keepassxc.org/>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 or (at your option)
# version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

FROM ubuntu:18.04

ENV REBUILD_COUNTER=0
ARG QT5_MINOR
ARG QT5_PATCH

ENV QT5_VERSION=qt5${QT5_MINOR}
ENV QT5_PPA_VERSION=qt-5.${QT5_MINOR}.${QT5_PATCH}

ENV LLVM_VERSION=10
ENV PATH="/usr/lib/llvm-${LLVM_VERSION}/bin:${PATH}"

RUN set -x \
    && apt-get update -y \
    && apt-get -y install --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        software-properties-common \
    && add-apt-repository ppa:beineri/opt-${QT5_PPA_VERSION}-bionic \
    && add-apt-repository ppa:phoerious/keepassxc \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y \
        asciidoctor \
        build-essential \
        clang-${LLVM_VERSION} \
        clang-format-${LLVM_VERSION} \
        cmake \
        curl \
        dbus \
        file \
        fuse \
        gcovr \
        git \
        libargon2-0-dev \
        libbotan-kpxc-2-dev \
        libgl1-mesa-dev \
        libgcrypt-dev \
        libomp-dev \
        libqrencode-dev \
        libquazip5-dev \
        libsodium-dev \
        libxi-dev \
        libxtst-dev \
        libyubikey-dev \
        libykpers-1-dev \
        libusb-1.0-0-dev \
        libpcsclite-dev \
        libminizip-dev \
        libkeyutils-dev \
        llvm-${LLVM_VERSION} \
        locales \
        metacity \
        ${QT5_VERSION}base \
        ${QT5_VERSION}svg \
        ${QT5_VERSION}imageformats \
        ${QT5_VERSION}tools \
        ${QT5_VERSION}translations \
        ${QT5_VERSION}x11extras \
        xclip \
        xvfb \
        zlib1g-dev \
        openssh-client \
    && apt-get autoremove --purge \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/
    
RUN set -x \
    && git clone https://github.com/ncopa/su-exec.git \
    && (cd su-exec; make) \
    && mv su-exec/su-exec /usr/bin/su-exec \
    && rm -rf su-exec

RUN set -x && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

ENV CMAKE_INCLUDE_PATH="/opt/keepassxc-libs/include:/opt/qt5${QT5_MINOR}/include"
ENV CMAKE_LIBRARY_PATH="/opt/keepassxc-libs/lib/x86_64-linux-gnu::/opt/qt5${QT5_MINOR}/lib"
ENV CPATH="${CMAKE_INCLUDE_PATH}"
ENV PATH="/opt/qt5${QT5_MINOR}/bin:${PATH}"

RUN set -x \
    && ln -s /opt/qt515/bin/qt5${QT5_MINOR}-env.sh /etc/profile.d/qt5${QT5_MINOR}-env.sh \
    && echo "/opt/qt5${QT5_MINOR}/lib" > /etc/ld.so.conf.d/01-qt5.conf \
    && echo "/opt/keepassxc-libs/lib/x86_64-linux-gnu" > /etc/ld.so.conf.d/02-keepassxc.conf \
    && ldconfig

RUN set -x \
    && curl -fL "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage" > /usr/local/bin/linuxdeploy \
    && curl -fL "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage" > /usr/local/bin/linuxdeploy-plugin-qt \
    && curl -fL "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" > /usr/local/bin/appimagetool \
    && curl -fL https://uploader.codecov.io/latest/linux/codecov > /usr/local/bin/codecov \
    && chmod +x /usr/local/bin/linuxdeploy \
    && chmod +x /usr/local/bin/linuxdeploy-plugin-qt \
    && chmod +x /usr/local/bin/appimagetool \
    && chmod +x /usr/local/bin/codecov \
    && ln -s /usr/bin/clang-format-10 /usr/bin/clang-format

RUN set -x \
    && groupadd -g 1000 keepassxc \
    && useradd -u 1000 -g keepassxc -d /keepassxc -s /bin/bash keepassxc

COPY docker-entrypoint.sh /docker-entrypoint.sh

VOLUME ["/keepassxc/src", "/keepassxc/out"]
WORKDIR /keepassxc
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bashx"]
