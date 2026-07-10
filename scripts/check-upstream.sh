#!/usr/bin/env bash
#
# Check upstream repositories for new release tags.
#
# Reads build.env and compares the current *_BRANCH value with the latest
# release tag in the upstream repository (via git ls-remote, so it also works
# for repos that only tag and never publish GitHub Releases, like the ODR
# tools). Tools pinned to a branch instead of a version tag (e.g. 'next')
# are skipped so deliberate branch pins stay intact.
#
# stdout: one tab-separated line per tool that has an update:
#   <tool>  <env_prefix>  <current_tag>  <latest_tag>  <new_version>  <repo>
# stderr: human-readable progress.
#
# Exit code is 0 whether or not updates were found; it is non-zero only on
# actual errors (e.g. unreachable upstream repository).

set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck disable=SC1091
. ./build.env

# Every <PREFIX>_REPO= line in build.env defines a tool; the tool name is the
# lowercased prefix (ODR_PADENC -> odr-padenc). ODR tools tag as v3.1.0 and
# DABlin as 1.16.1, so a release tag is any dotted version with an optional
# 'v'; our release VERSION always keeps the 'v' (DABLIN_VERSION=v1.16.1).
TAG_REGEX='^v?[0-9]+\.[0-9]+(\.[0-9]+)?$'

# shellcheck disable=SC2013 # prefixes are single words, word-splitting is intended
for prefix in $(sed -n 's/^\([A-Z_]*\)_REPO=.*/\1/p' build.env); do
  tool=$(tr '[:upper:]_' '[:lower:]-' <<< "$prefix")
  repo_var="${prefix}_REPO"
  branch_var="${prefix}_BRANCH"
  repo="${!repo_var}"
  current="${!branch_var}"

  if ! [[ "$current" =~ $TAG_REGEX ]]; then
    echo "SKIP    ${tool}: pinned to branch '${current}', not tracking releases" >&2
    continue
  fi

  # grep is wrapped so a repo without matching tags hits the WARN path
  # below instead of tripping pipefail
  latest=$(git ls-remote --tags --refs "$repo" \
    | awk -F/ '{print $NF}' \
    | { grep -E "$TAG_REGEX" || true; } \
    | sort -V \
    | tail -n1)

  if [ -z "$latest" ]; then
    echo "WARN    ${tool}: no release tags found in ${repo}" >&2
    continue
  fi

  # sort -V picks the newer of the two; if that is the current tag we are up
  # to date (or deliberately ahead of upstream, e.g. on a fork tag)
  if [ "$(printf '%s\n%s\n' "$current" "$latest" | sort -V | tail -n1)" = "$current" ]; then
    echo "OK      ${tool}: up to date (current ${current}, latest upstream ${latest})" >&2
    continue
  fi

  version="$latest"
  [[ "$version" == v* ]] || version="v${version}"

  echo "UPDATE  ${tool}: ${current} -> ${latest}" >&2
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$tool" "$prefix" "$current" "$latest" "$version" "$repo"
done
