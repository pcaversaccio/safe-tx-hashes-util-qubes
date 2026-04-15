# Qubes OS Environment for Safe Multisig Transaction Hashes

[![👮‍♂️ Sanity checks](https://github.com/pcaversaccio/safe-tx-hashes-util-qubes/actions/workflows/checks.yml/badge.svg)](https://github.com/pcaversaccio/safe-tx-hashes-util-qubes/actions/workflows/checks.yml)
[![License: AGPL-3.0-only](https://img.shields.io/badge/License-AGPL--3.0--only-blue)](https://www.gnu.org/licenses/agpl-3.0)

A [Qubes OS](https://www.qubes-os.org) [Salt](https://doc.qubes-os.org/en/latest/user/advanced-topics/salt.html) configuration for building a minimal, reproducible template VM providing the [`safe-tx-hashes-util`](https://github.com/pcaversaccio/safe-tx-hashes-util) and [Foundry](https://github.com/foundry-rs/foundry) toolchain.

## Installation (`dom0`)

```console
# Copy Salt states.
sudo mkdir -p /srv/salt
sudo cp -r safe-tx-hashes-util-qubes/safe-tx-hashes-util /srv/salt/

# Create and provision the template.
sudo qubesctl state.apply safe-tx-hashes-util
```

## What This Setup Provides

- Creates a [minimal](https://doc.qubes-os.org/en/latest/user/templates/minimal-templates.html) [Fedora 43](https://www.qubes-os.org/news/2026/02/06/fedora-43-templates-available/)-based template VM (`safe-tx-hashes-util-template`).
- Installs [Foundry](https://github.com/foundry-rs/foundry) from a verified pinned GitHub release (locally version-controlled).
- Installs [`safe-tx-hashes-util`](https://github.com/pcaversaccio/safe-tx-hashes-util) into `/opt/safe-tx-hashes-util`.
- Removes build-time dependencies after installation.
