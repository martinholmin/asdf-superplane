# Shared helpers for the superplane asdf plugin.
set -euo pipefail

REPO="superplanehq/superplane"
GH_RELEASES="https://github.com/${REPO}/releases/download"

fail() { echo "asdf-superplane: $*" >&2; exit 1; }

curl_opts=(-fsSL)
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts+=(-H "Authorization: token ${GITHUB_API_TOKEN}")
fi

# CLI binaries ship on two tag lines: cli/vX (1.x onwards) and vX (0.x).
# asdf versions drop the prefix: 1.0.0-rc1 -> cli/v1.0.0-rc1, 0.29.0 -> v0.29.0.
list_versions() {
  curl "${curl_opts[@]}" "https://api.github.com/repos/${REPO}/releases?per_page=100" |
    python3 -c '
import json, sys
for r in json.load(sys.stdin):
    if not any(a["name"].startswith("superplane-cli-") for a in r["assets"]):
        continue
    t = r["tag_name"]
    if t.startswith("cli/v"): print(t[5:])
    elif t.startswith("v"): print(t[1:])
' | sort -V
}

tag_for() {
  local v="$1"
  if curl -fsSIo /dev/null "${GH_RELEASES}/cli/v${v}/superplane-cli-linux-amd64"; then
    echo "cli/v${v}"
  else
    echo "v${v}"
  fi
}

platform() {
  local os arch
  case "$(uname -s)" in
    Darwin) os=darwin ;; Linux) os=linux ;; *) fail "unsupported OS $(uname -s)" ;;
  esac
  case "$(uname -m)" in
    x86_64 | amd64) arch=amd64 ;; arm64 | aarch64) arch=arm64 ;; *) fail "unsupported arch $(uname -m)" ;;
  esac
  echo "${os}-${arch}"
}

sha256() {
  if command -v sha256sum >/dev/null; then sha256sum "$1" | cut -d' ' -f1
  else shasum -a 256 "$1" | cut -d' ' -f1; fi
}
