<div align="center">

# asdf-superplane [![Build](https://github.com/martinholmin/asdf-superplane/actions/workflows/build.yml/badge.svg)](https://github.com/martinholmin/asdf-superplane/actions/workflows/build.yml) [![Lint](https://github.com/martinholmin/asdf-superplane/actions/workflows/lint.yml/badge.svg)](https://github.com/martinholmin/asdf-superplane/actions/workflows/lint.yml)

[SuperPlane](https://github.com/superplanehq/superplane) CLI plugin for the [asdf version manager](https://asdf-vm.com).

</div>

> [!NOTE]
> This is an unofficial, community plugin. It is not affiliated with, endorsed by, or
> supported by the SuperPlane project. SuperPlane and its CLI are entirely the work of
> the [SuperPlane authors](https://github.com/superplanehq/superplane); this repository
> contains no SuperPlane code and only downloads the official release binaries.

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Versions](#versions)
- [Checksum verification](#checksum-verification)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, and generic POSIX utilities (`awk`, `sed`, `sort`).
- `sha256sum` or `shasum`, for checksum verification.

Supported platforms are the ones upstream publishes binaries for: Linux and macOS, on
amd64 and arm64.

# Install

Plugin:

```shell
asdf plugin add superplane https://github.com/martinholmin/asdf-superplane.git
```

superplane:

```shell
# Show all installable versions
asdf list all superplane

# Install a specific version
asdf install superplane 1.0.0-rc1

# Set a version globally (in your ~/.tool-versions file)
asdf set -u superplane 1.0.0-rc1

# Now superplane commands are available
superplane --help
```

Check the [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install and manage versions.

Set `GITHUB_API_TOKEN` to a GitHub token if `asdf list all superplane` hits the GitHub
API rate limit.

# Versions

Every upstream release that ships a CLI binary is installable, from `0.1.3` onwards.
Versions are the upstream release tags without their prefix:

| asdf version           | Upstream tag     | Release asset                           |
| ---------------------- | ---------------- | --------------------------------------- |
| `1.0.0-rc1` and later  | `cli/v<version>` | `superplane-cli-<os>-<arch>`            |
| `0.1.6` to `1.0.0-rc2` | `v<version>`     | `superplane-cli-<os>-<arch>`            |
| `0.1.3` to `0.1.5`     | `v<version>`     | `superplane-cli-v<version>-<os>-<arch>` |

Things worth knowing:

- When a version exists on both tag lines, the dedicated `cli/v<version>` release wins.
- `1.0.0-rc2` is older than `1.0.0-rc1`. `1.0.0-rc2` comes from the server tag
  `v1.0.0-rc2`, the last server release that bundled a CLI; `1.0.0-rc1` resolves to
  `cli/v1.0.0-rc1`, which was published after it.
- `asdf latest superplane` skips pre-releases, so it reports the newest `0.x` version
  until upstream publishes a final `1.x` CLI release. Pin a `1.x` release candidate
  explicitly if you talk to a `1.x` server.

# Checksum verification

Downloads are verified against the SHA-256 in the release's `checksums.txt`, and the
install is aborted on a mismatch. Releases before `1.0.0-rc1` do not publish checksums;
those install with a warning instead.

# Contributing

Issues and pull requests are welcome. Scripts are linted with
[ShellCheck](https://www.shellcheck.net) (`shellcheck -x bin/* lib/utils.bash`), and CI
installs one version per upstream release layout on Linux and macOS.

For problems with the SuperPlane CLI itself, please report them
[upstream](https://github.com/superplanehq/superplane/issues).

# License

The plugin scripts in this repository are released under the [MIT License](LICENSE).

That license covers this plugin only. SuperPlane itself is licensed separately by its
authors; see the [upstream license](https://github.com/superplanehq/superplane/blob/main/LICENSE).
