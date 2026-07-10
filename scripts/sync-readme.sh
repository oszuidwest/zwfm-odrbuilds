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

# $1: bold label in the tool list (binary/image name is its lowercase),
# $2: version
sync() {
  local label="$1" version="$2" slug
  slug=$(tr '[:upper:]' '[:lower:]' <<< "$label")
  sed -E -i.bak \
    -e "s#(\*\*${label}\*\* \()(v?[0-9][0-9.]*|next)(\))#\1${version}\3#" \
    -e "s#(${slug}[-:])(v?[0-9][0-9.]*|next)#\1${version}#g" \
    README.md
  rm -f README.md.bak
  # A README restyle that the patterns above no longer match would silently
  # stop syncing this tool; demand that its reference still exists
  grep -qE "(\*\*${label}\*\* \(|${slug}[-:])${version}" README.md || {
    echo "ERROR: no ${label} ${version} reference left in README.md" >&2
    exit 1
  }
}

sync "ODR-PadEnc" "$ODR_PADENC_VERSION"
sync "ODR-AudioEnc" "$ODR_AUDIOENC_VERSION"
sync "ODR-DabMux" "$ODR_DABMUX_VERSION"
sync "DABlin" "$DABLIN_VERSION"

# Tripwire: every version-shaped token (v + dotted digits) left in the
# README must be one of the build.env versions; anything else is a stale
# reference the patterns above no longer reach. Requiring the dot keeps
# prose like "IPv6" out of the match.
stale=$(grep -oE 'v[0-9]+\.[0-9][0-9.]*' README.md \
  | grep -vxF -e "$ODR_PADENC_VERSION" -e "$ODR_AUDIOENC_VERSION" \
      -e "$ODR_DABMUX_VERSION" -e "$DABLIN_VERSION" || true)
if [ -n "$stale" ]; then
  echo "ERROR: README.md has version references not in build.env:" >&2
  echo "$stale" >&2
  exit 1
fi
