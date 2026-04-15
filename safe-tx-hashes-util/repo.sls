install_safe_tx_hashes_util:
  cmd.run:
    - name: |
        echo "[Safe Multisig Transaction Hashes] Cloning "safe-tx-hashes-util" repository..."
        git clone https://github.com/pcaversaccio/safe-tx-hashes-util /opt/safe-tx-hashes-util
        chmod 555 /opt/safe-tx-hashes-util/safe_hashes.sh
        chown root:root /opt/safe-tx-hashes-util/safe_hashes.sh
