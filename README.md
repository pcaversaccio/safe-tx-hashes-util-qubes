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
- Installs [`safe-tx-hashes-util`](https://github.com/pcaversaccio/safe-tx-hashes-util) into `/opt/safe-tx-hashes-util`.
- Removes build-time dependencies after installation.
