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
#   <tool>  <env_prefix>  <current_tag>  <latest_tag>  <new_version>
# stderr: human-readable progress.
#
# Exit code is 0 whether or not updates were found; it is non-zero only on
# actual errors (e.g. unreachable upstream repository).

set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck disable=SC1091
. ./build.env

# Format: tool|env prefix|tag regex|version prefix
# ODR tools tag as v3.1.0; DABlin tags without the 'v' prefix (1.16.1), but
# our release version keeps the 'v' (DABLIN_VERSION=v1.16.1), hence the
# version prefix column.
TOOLS='odr-padenc|ODR_PADENC|^v[0-9]+\.[0-9]+(\.[0-9]+)?$|
odr-audioenc|ODR_AUDIOENC|^v[0-9]+\.[0-9]+(\.[0-9]+)?$|
odr-dabmux|ODR_DABMUX|^v[0-9]+\.[0-9]+(\.[0-9]+)?$|
dablin|DABLIN|^[0-9]+\.[0-9]+(\.[0-9]+)?$|v'

while IFS='|' read -r tool prefix regex vprefix; do
  [ -z "$tool" ] && continue

  repo_var="${prefix}_REPO"
  branch_var="${prefix}_BRANCH"
  repo="${!repo_var}"
  current="${!branch_var}"

  if ! [[ "$current" =~ $regex ]]; then
    echo "SKIP    ${tool}: pinned to branch '${current}', not tracking releases" >&2
    continue
  fi

  # grep is wrapped so a repo without matching tags hits the WARN path
  # below instead of tripping pipefail
  latest=$(git ls-remote --tags --refs "$repo" \
    | awk -F/ '{print $NF}' \
    | { grep -E "$regex" || true; } \
    | sort -V \
    | tail -n1)

  if [ -z "$latest" ]; then
    echo "WARN    ${tool}: no release tags found in ${repo}" >&2
    continue
  fi

  if [ "$latest" = "$current" ]; then
    echo "OK      ${tool}: up to date (${current})" >&2
    continue
  fi

  newest=$(printf '%s\n%s\n' "$current" "$latest" | sort -V | tail -n1)
  if [ "$newest" != "$latest" ]; then
    echo "OK      ${tool}: current ${current} is newer than upstream ${latest}" >&2
    continue
  fi

  echo "UPDATE  ${tool}: ${current} -> ${latest}" >&2
  printf '%s\t%s\t%s\t%s\t%s\n' "$tool" "$prefix" "$current" "$latest" "${vprefix}${latest}"
done <<< "$TOOLS"
