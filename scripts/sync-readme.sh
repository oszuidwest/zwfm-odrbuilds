#!/usr/bin/env bash
#
# Sync version references in README.md with build.env.
#
# Rewrites the tool list bullets, binary names in examples, download URLs
# and Docker tags. All patterns are anchored to the tool name so identical
# version numbers of different tools can never cross-contaminate.
# Idempotent: running it twice is a no-op.

set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck disable=SC1091
. ./build.env

# $1: bold label in the tool list, $2: binary/image name, $3: version
sync() {
  local label="$1" slug="$2" version="$3"
  sed -E -i.bak \
    -e "s#(\*\*${label}\*\* \()(v?[0-9][0-9.]*|next)(\))#\1${version}\3#" \
    -e "s#(${slug}[-:])(v?[0-9][0-9.]*|next)#\1${version}#g" \
    README.md
  rm -f README.md.bak
}

orig=$(mktemp)
cp README.md "$orig"

sync "ODR-PadEnc" "odr-padenc" "$ODR_PADENC_VERSION"
sync "ODR-AudioEnc" "odr-audioenc" "$ODR_AUDIOENC_VERSION"
sync "ODR-DabMux" "odr-dabmux" "$ODR_DABMUX_VERSION"
sync "DABlin" "dablin" "$DABLIN_VERSION"

if cmp -s "$orig" README.md; then
  echo "README.md already in sync with build.env" >&2
else
  echo "README.md updated from build.env" >&2
fi
rm -f "$orig"
