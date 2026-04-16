cleanup_packages:
  cmd.run:
    - name: |
        set -Eeuo pipefail
        echo "[Cleanup] Removing build dependencies..."
        dnf remove -y git
        dnf clean all
    - require:
        - cmd: install_foundry
        - cmd: install_safe_tx_hashes_util
