# Qubes OS Environment for Safe Multisig Transaction Hashes <!-- omit from toc -->

[![👮‍♂️ Sanity checks](https://github.com/pcaversaccio/safe-tx-hashes-util-qubes/actions/workflows/checks.yml/badge.svg)](https://github.com/pcaversaccio/safe-tx-hashes-util-qubes/actions/workflows/checks.yml)
[![License: AGPL-3.0-only](https://img.shields.io/badge/License-AGPL--3.0--only-blue)](https://www.gnu.org/licenses/agpl-3.0)

A [Qubes OS](https://www.qubes-os.org) [Salt](https://doc.qubes-os.org/en/latest/user/advanced-topics/salt.html) configuration for building a minimal, reproducible _template VM_ providing the [`safe-tx-hashes-util`](https://github.com/pcaversaccio/safe-tx-hashes-util) and [Foundry](https://github.com/foundry-rs/foundry) toolchain.

> [!IMPORTANT]
> This repository has been tested exclusively on [Qubes OS](https://www.qubes-os.org) [`4.3`](https://doc.qubes-os.org/en/latest/developer/releases/4_3/release-notes.html).

- [Installation (`dom0`)](#installation-dom0)
- [What This Setup Provides](#what-this-setup-provides)
- [Trust Assumptions](#trust-assumptions)
  - [1. The `fedora-43-minimal` Template](#1-the-fedora-43-minimal-template)
  - [2. This Salt Configuration](#2-this-salt-configuration)
  - [3. The `safe-tx-hashes-util` Script](#3-the-safe-tx-hashes-util-script)
  - [Summary Table](#summary-table)
- [Firefox (Optional)](#firefox-optional)

## Installation ([`dom0`](https://doc.qubes-os.org/en/latest/user/reference/glossary.html#term-dom0))

Because the [Qubes OS](https://www.qubes-os.org) administrative domain [`dom0`](https://doc.qubes-os.org/en/latest/user/reference/glossary.html#term-dom0) is offline by design, you must first download the repository in a network-connected [AppVM](https://doc.qubes-os.org/en/latest/user/reference/glossary.html#term-app-qube) (e.g., an [AppVM](https://doc.qubes-os.org/en/latest/user/reference/glossary.html#term-app-qube) named `dev`), and then securely transfer it to [`dom0`](https://doc.qubes-os.org/en/latest/user/reference/glossary.html#term-dom0).

1. In your `dev` [AppVM](https://doc.qubes-os.org/en/latest/user/reference/glossary.html#term-app-qube) open a terminal and fetch the repository:

```console
~$ git clone https://github.com/pcaversaccio/safe-tx-hashes-util-qubes.git
~$ tar -czf repo.tar.gz safe-tx-hashes-util-qubes
```

2. In [`dom0`](https://doc.qubes-os.org/en/latest/user/reference/glossary.html#term-dom0) open a terminal and securely pull the archive from your `dev` qube:

```console
# Pull the archive from the `dev` AppVM.
~$ qvm-run -p dev 'cat repo.tar.gz' > repo.tar.gz
~$ tar -xzf repo.tar.gz

# IMPORTANT: You must read every `.sls` file before applying them!
# Inspect the Salt files before proceeding, e.g.:
~$ cat safe-tx-hashes-util-qubes/safe-tx-hashes-util/init.sls

# Move the Salt states to the central Salt directory.
~$ sudo mkdir -p /srv/salt
~$ sudo cp -r safe-tx-hashes-util-qubes/safe-tx-hashes-util /srv/salt/

# Provision the environment.
~$ sudo qubesctl state.apply safe-tx-hashes-util

# Clean up `dom0`.
~$ rm -rf repo.tar.gz safe-tx-hashes-util-qubes

# (Optional) Remove the Salt states if you do not plan to rebuild or update the template.
~$ sudo rm -rf /srv/salt/safe-tx-hashes-util
```

3. Eventually, clean up the `dev` [AppVM](https://doc.qubes-os.org/en/latest/user/reference/glossary.html#term-app-qube):

```console
~$ rm -rf repo.tar.gz safe-tx-hashes-util-qubes
```

## What This Setup Provides

- Creates a [minimal](https://doc.qubes-os.org/en/latest/user/templates/minimal-templates.html) [Fedora 43](https://www.qubes-os.org/news/2026/02/06/fedora-43-templates-available/)-based template VM (`safe-tx-hashes-util-template`).
- Installs [Foundry](https://github.com/foundry-rs/foundry) from a _verified_ pinned GitHub release (locally version-controlled).
- Installs [`safe-tx-hashes-util`](https://github.com/pcaversaccio/safe-tx-hashes-util) into `/opt/safe-tx-hashes-util` at a pinned, _verified_ commit.
- Removes build-time dependencies after installation.
- Optionally ships [Firefox](https://www.firefox.com) for GUI-based transaction inspection. For a _terminal-only_ setup, delete the `firefox` line in [`packages.sls`](./safe-tx-hashes-util/packages.sls) before provisioning.

## Trust Assumptions

This setup does **not** eliminate trust - it makes the trust surface _explicit_ and _minimal_. When you use this environment to verify Safe multisig transaction hashes, you are trusting the following:

### 1. The [`fedora-43-minimal`](https://www.qubes-os.org/news/2026/02/06/fedora-43-templates-available/) Template

All system packages (`bash`, `coreutils`, `curl`, `jq`, `ca-certificates`, etc.) are installed via [`dnf`](https://github.com/rpm-software-management/dnf) from [Fedora](https://fedoraproject.org)'s signed repositories. This means you trust:

- The [Fedora](https://fedoraproject.org) project's package signing keys and their key-management practices.
- The integrity of the [Qubes OS](https://www.qubes-os.org) [`fedora-43-minimal`](https://www.qubes-os.org/news/2026/02/06/fedora-43-templates-available/) template as shipped by the [Qubes OS](https://www.qubes-os.org) project.

[Fedora](https://fedoraproject.org)'s package signatures are verified automatically by [`dnf`](https://github.com/rpm-software-management/dnf). No additional pinning of system packages is applied, because the [Fedora](https://fedoraproject.org)-signed repository is already the trust anchor for these artifacts (the same trust anchor that [Qubes OS](https://www.qubes-os.org) itself relies on). After provisioning, the installed versions of key tools are recorded to `/var/log/safe-tx-hashes-util-versions.log` inside the template for auditability.

### 2. This Salt Configuration

You trust the [Salt](https://doc.qubes-os.org/en/latest/user/advanced-topics/salt.html) state files in this repository (the `.sls` files in [`safe-tx-hashes-util/`](./safe-tx-hashes-util)) to provision the template correctly and not introduce malicious behaviour. **You must read every `.sls` file before applying them.** The installation instructions above include an explicit inspection step for this reason.

Notable integrity controls already present in this config:

- [Foundry](https://github.com/foundry-rs/foundry) is downloaded from a pinned GitHub release tag and its tarball is verified against a hardcoded SHA-256 hash before any binary is executed.
- [`safe-tx-hashes-util`](https://github.com/pcaversaccio/safe-tx-hashes-util) is cloned and then checked out to a pinned commit SHA, which is re-verified after checkout.
- Build dependencies (`git`) are removed after installation, shrinking the runtime attack surface.

### 3. The [`safe-tx-hashes-util`](https://github.com/pcaversaccio/safe-tx-hashes-util) Script

You trust [`safe_hashes.sh`](https://github.com/pcaversaccio/safe-tx-hashes-util/blob/main/safe_hashes.sh) to correctly compute and display Safe transaction hashes. The script is installed _read-only_ (`chmod 555`) and owned by `root`. It is pinned to a specific commit in [`repo.sls`](./safe-tx-hashes-util/repo.sls) (update `PINNED_COMMIT` deliberately and only after reviewing the diff when upgrading).

### Summary Table

| Component                           | Trust Anchor                  | Integrity Control                         |
| ----------------------------------- | ----------------------------- | ----------------------------------------- |
| Fedora 43 minimal template          | Qubes OS project              | Qubes OS template verification            |
| System packages (`jq`, `curl`, ...) | Fedora project GPG keys       | `dnf` GPG signature check                 |
| Foundry binaries                    | This repo's hardcoded SHA-256 | `sha256sum -c` before extraction          |
| `safe-tx-hashes-util` script        | This repo's pinned commit SHA | `git checkout` + `rev-parse` verification |
| This Salt config itself             | You, by reading it            | Manual inspection before `qubesctl`       |

## Firefox (Optional)

The [`packages.sls`](./safe-tx-hashes-util/packages.sls) file includes [`firefox`](https://www.firefox.com) by default, but it is entirely _optional_. If you prefer a _terminal-only_ setup (for example, to further reduce the template's attack surface or because you verify transactions exclusively via the CLI) simply remove the [`firefox`](https://www.firefox.com) line from [`packages.sls`](./safe-tx-hashes-util/packages.sls) before running `qubesctl state.apply`.
