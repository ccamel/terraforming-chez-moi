#!/bin/sh
set -eu

if [ ! -c /dev/net/tun ]; then
  if ! grep -q '^tun ' /proc/modules; then
    /usr/sbin/insmod /lib/modules/tun.ko
  fi
  mkdir -p /dev/net
  mknod /dev/net/tun c 10 200
  chmod 600 /dev/net/tun
fi

cd /volume1/projects/transmission
exec /usr/bin/docker compose -p transmission up -d
