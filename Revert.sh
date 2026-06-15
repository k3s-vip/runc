#!/bin/bash

set -e

readonly OLD=github.com/opencontainers/runc/libcontainer/cgroups
readonly NEW=github.com/opencontainers/cgroups

if grep $NEW -rl | grep .go$; then
  echo "Revert: Switch to opencontainers/cgroups"
  git revert a75076b4a413f628c4b6aa4c5568b159aa128a56
else
  exit
fi
VERSION=0.0.5
wget -qO- https://$NEW/archive/refs/tags/v$VERSION.tar.gz | tar -xz
find cgroups-$VERSION -type f | while read -r f; do
  if [[ $f =~ .go$ ]]; then
    fn="libcontainer/cgroups/${f#*/}"
    mkdir -p "${fn%/*}"
    mv "$f" "$fn"
  else
    rm "$f"
  fi
done

grep $NEW -rl | grep .go$ | grep -v /vendor/ | while read -r f; do
  sed "s~$NEW~$OLD~g" "$f" >"$f.sed"
  mv "$f.sed" "$f"
done
