#!/bin/sh
set -eu

echo "forge:${GIT_PASSWORD:-forge}" | chpasswd
chown -R forge:forge /git
ssh-keygen -A
exec /usr/sbin/sshd -D -e -o PasswordAuthentication=yes -o PermitRootLogin=no -o AllowUsers=forge
