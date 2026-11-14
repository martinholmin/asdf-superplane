# asdf-superplane

asdf plugin for the [SuperPlane](https://github.com/superplanehq/superplane) CLI.
Installs the prebuilt `superplane-cli-<os>-<arch>` release asset and verifies it against the
release's `checksums.txt` (0.x releases publish none and install with a warning).

Versions drop the tag prefix: `1.0.0-rc1` is tag `cli/v1.0.0-rc1`, `0.29.0` is `v0.29.0`.
The upstream install script's "latest" still redirects to 0.29.0, which predates the 1.x server.

```sh
asdf plugin add superplane ~/Code/martinholmin/asdf-superplane
asdf install superplane 1.0.0-rc1
asdf set -u superplane 1.0.0-rc1
```

Set `GITHUB_API_TOKEN` if `list-all` hits the GitHub API rate limit.
