FROM kalilinux/kali-rolling:latest

ARG DEBIAN_FRONTEND=noninteractive

# set version for s6 overlay
ARG S6_OVERLAY_VERSION="3.2.0.0"
ARG S6_OVERLAY_ARCH="x86_64"

RUN \
  apt update && \
  apt install -y \
    xz-utils

# add s6 overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz

# add s6 optional symlinks
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz

ENTRYPOINT ["/init"]

RUN \
  apt-get update && \
  apt-get install -y \
    kali-desktop-lxde && \
  echo "**** cleanup ****" && \
  apt remove clipit -y && \
  apt-get autoremove -y && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

RUN \
  echo "**** install noVNC ****" && \
  apt-get update && \
  apt-get install -y \
    tigervnc-standalone-server \
    nginx \
    novnc && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

COPY /root /

RUN \
  chmod 744 /etc/s6-overlay/s6-rc.d/*/run

# ports and volumes
EXPOSE 6080
