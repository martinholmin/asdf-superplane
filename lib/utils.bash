# Shared helpers for the superplane asdf plugin.
# shellcheck shell=bash
set -euo pipefail

REPO="superplanehq/superplane"
# shellcheck disable=SC2034  # used by bin/download
GH_RELEASES="https://github.com/${REPO}/releases/download"
GH_API="https://api.github.com/repos/${REPO}/releases"

fail() {
  echo "asdf-superplane: $*" >&2
  exit 1
}

curl_opts=(-fsSL)
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts+=(-H "Authorization: token ${GITHUB_API_TOKEN}")
fi

# Semver-ish sort that puts pre-releases (1.0.0-rc1) before their final release (1.0.0).
sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

# The upstream repo also releases a server, a runner and a fleet manager, so only
# releases that carry a CLI binary are listed. asdf versions drop the tag prefix:
# 1.0.0-rc1 -> cli/v1.0.0-rc1, 0.29.0 -> v0.29.0.
list_versions() {
  local page=1 body
  while :; do
    body="$(curl "${curl_opts[@]}" "${GH_API}?per_page=100&page=${page}")" ||
      fail "could not list releases (set GITHUB_API_TOKEN if you are rate limited)"
    grep -q '"tag_name"' <<<"$body" || break
    awk -F'"' '
      $2 == "tag_name" { tag = $4 }
      $2 == "name" && tag != "" && $4 ~ /^superplane-cli-(v[0-9.]+-)?(darwin|linux)-/ { print tag; tag = "" }
    ' <<<"$body"
    page=$((page + 1))
  done | sed -n 's|^cli/v||p; s|^v||p' | sort_versions | uniq
}

# Where a version's binary can live, most recent layout first, as "<tag> <asset>" lines:
#   cli/vX  superplane-cli-<os>-<arch>      dedicated CLI releases (1.x onwards)
#   vX      superplane-cli-<os>-<arch>      0.1.6 up to 1.0.0-rc2
#   vX      superplane-cli-vX-<os>-<arch>   0.1.3 up to 0.1.5
release_candidates() {
  local version="$1" platform="$2"
  echo "cli/v${version} superplane-cli-${platform}"
  echo "v${version} superplane-cli-${platform}"
  echo "v${version} superplane-cli-v${version}-${platform}"
}

platform() {
  local os arch
  case "$(uname -s)" in
    Darwin) os=darwin ;;
    Linux) os=linux ;;
    *) fail "unsupported OS $(uname -s)" ;;
  esac
  case "$(uname -m)" in
    x86_64 | amd64) arch=amd64 ;;
    arm64 | aarch64) arch=arm64 ;;
    *) fail "unsupported architecture $(uname -m)" ;;
  esac
  echo "${os}-${arch}"
}

sha256() {
  if command -v sha256sum >/dev/null; then
    sha256sum "$1" | cut -d' ' -f1
  else
    shasum -a 256 "$1" | cut -d' ' -f1
  fi
}
