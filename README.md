# Qubes OS Environment for Safe Multisig Transaction Hashes

[![👮‍♂️ Sanity checks](https://github.com/pcaversaccio/safe-tx-hashes-util-qubes/actions/workflows/checks.yml/badge.svg)](https://github.com/pcaversaccio/safe-tx-hashes-util-qubes/actions/workflows/checks.yml)
[![License: AGPL-3.0-only](https://img.shields.io/badge/License-AGPL--3.0--only-blue)](https://www.gnu.org/licenses/agpl-3.0)

A [Qubes OS](https://www.qubes-os.org) [Salt](https://doc.qubes-os.org/en/latest/user/advanced-topics/salt.html) configuration for building a minimal, reproducible template VM providing the [`safe-tx-hashes-util`](https://github.com/pcaversaccio/safe-tx-hashes-util) and [Foundry](https://github.com/foundry-rs/foundry) toolchain.

## Installation (`dom0`)

Because the Qubes administrative domain (`dom0`) is offline by design, you must first download the repository in a network-connected AppVM (e.g., an AppVM named `dev`), and then securely transfer it to `dom0`.

1. In your `dev` AppVM open a terminal and fetch the repository:

```console
~$ git clone https://github.com/pcaversaccio/safe-tx-hashes-util-qubes.git
~$ tar czf repo.tar.gz safe-tx-hashes-util-qubes
```

2. In `dom0` open a terminal and securely pull the archive from your `dev` qube:

```console
# Pull the archive from the `dev` AppVM.
~$ qvm-run -p dev 'cat repo.tar.gz' > repo.tar.gz
~$ tar xzf repo.tar.gz

# (Optional but recommended) Inspect the Salt files before proceeding.
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

3. Eventually, clean up the `dev` AppVM:

```console
~$ rm -rf repo.tar.gz safe-tx-hashes-util-qubes
```

## What This Setup Provides

- Creates a [minimal](https://doc.qubes-os.org/en/latest/user/templates/minimal-templates.html) [Fedora 43](https://www.qubes-os.org/news/2026/02/06/fedora-43-templates-available/)-based template VM (`safe-tx-hashes-util-template`).
- Installs [Foundry](https://github.com/foundry-rs/foundry) from a verified pinned GitHub release (locally version-controlled).
- Installs [`safe-tx-hashes-util`](https://github.com/pcaversaccio/safe-tx-hashes-util) into `/opt/safe-tx-hashes-util` at a pinned, verified commit.
- Removes build-time dependencies after installation.
- Optionally ships [Firefox](https://www.mozilla.org/en-US/firefox/) for GUI-based transaction inspection — **remove it for a terminal-only setup** by deleting the `firefox` line in [`packages.sls`](./safe-tx-hashes-util/packages.sls) before provisioning.

## Trust Assumptions

This setup does **not** eliminate trust — it makes the trust surface explicit and minimal. When you use this environment to verify Safe multisig transaction hashes, you are trusting the following:

### 1. The Fedora 43 Minimal Template

All system packages (`bash`, `coreutils`, `curl`, `jq`, `ca-certificates`, etc.) are installed via `dnf` from Fedora's signed repositories. This means you trust:

- The Fedora Project's package signing keys and their key-management practices.
- The integrity of the Qubes OS `fedora-43-minimal` template as shipped by the Qubes OS Project.

Fedora's package signatures are verified automatically by `dnf`. No additional pinning of system packages is applied, because the Fedora-signed repository is already the trust anchor for these artifacts — the same trust anchor that Qubes OS itself relies on. After provisioning, installed versions of key tools are recorded to `/var/log/safe-tx-hashes-util-versions.log` inside the template for auditability.

### 2. This Salt Configuration

You trust the Salt state files in this repository (the `.sls` files) to provision the template correctly and not introduce malicious behaviour. **You should read every `.sls` file before applying them.** The installation instructions above include an explicit inspection step for this reason.

Notable integrity controls already present in this config:

- Foundry is downloaded from a pinned GitHub release tag and its tarball is verified against a hardcoded SHA-256 before any binary is executed.
- `safe-tx-hashes-util` is cloned and then checked out to a pinned commit SHA, which is re-verified after checkout.
- Build dependencies (`git`) are removed after installation, shrinking the runtime attack surface.

### 3. The `safe-tx-hashes-util` Script

You trust [`safe_hashes.sh`](https://github.com/pcaversaccio/safe-tx-hashes-util) to correctly compute and display Safe transaction hashes. The script is installed read-only (`chmod 555`) and owned by `root`. It is pinned to a specific commit in `repo.sls` — update `PINNED_COMMIT` deliberately and only after reviewing the diff when upgrading.

### Summary Table

| Component                         | Trust anchor                  | Integrity control                         |
| --------------------------------- | ----------------------------- | ----------------------------------------- |
| Fedora 43 minimal template        | Qubes OS Project              | Qubes OS template verification            |
| System packages (`jq`, `curl`, …) | Fedora Project GPG keys       | `dnf` GPG signature check                 |
| Foundry binaries                  | This repo's hardcoded SHA-256 | `sha256sum -c` before extraction          |
| `safe-tx-hashes-util` script      | This repo's pinned commit SHA | `git checkout` + `rev-parse` verification |
| This Salt config itself           | You, by reading it            | Manual inspection before `qubesctl`       |

## Firefox (Optional)

The `packages.sls` file includes `firefox` by default, which allows you to open the [Safe web app](https://app.safe.global) inside the isolated AppVM and compare what the UI displays against the hashes computed by `safe_hashes.sh`. **Firefox is entirely optional.** If you prefer a terminal-only setup — for example, to further reduce the template's attack surface or because you verify transactions exclusively via the CLI — simply remove the `firefox` line from [`packages.sls`](./safe-tx-hashes-util/packages.sls) before running `qubesctl state.apply`.
