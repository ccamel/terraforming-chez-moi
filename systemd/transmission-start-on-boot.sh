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

if ! grep -q ' /volume1/docker/download cifs ' /proc/mounts; then
  /usr/syno/bin/synomount --resume
fi
grep -q ' /volume1/docker/download cifs ' /proc/mounts

cd /volume1/projects/transmission
/usr/bin/docker compose -p transmission up -d
/usr/bin/docker wait transmission >/dev/null
exit 1
