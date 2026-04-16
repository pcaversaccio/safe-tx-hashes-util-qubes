install_safe_tx_hashes_util:
  cmd.run:
    - env:
        - http_proxy: http://127.0.0.1:8082
        - https_proxy: http://127.0.0.1:8082
    - unless: test -d /opt/safe-tx-hashes-util
    - name: |
        set -Eeuo pipefail

        readonly PINNED_COMMIT="fd989f2aa2445a81dba508470ea1120b5dfee371" # See https://github.com/pcaversaccio/safe-tx-hashes-util/commits/main.
        readonly REPO_URL="https://github.com/pcaversaccio/safe-tx-hashes-util"

        echo "[safe-tx-hashes-util] Cloning repository..."
        git clone "$REPO_URL" /opt/safe-tx-hashes-util

        echo "[safe-tx-hashes-util] Checking out pinned commit \`${PINNED_COMMIT}\`..."
        git -C /opt/safe-tx-hashes-util checkout "$PINNED_COMMIT"

        echo "[safe-tx-hashes-util] Verifying checked-out commit..."
        readonly actual=$(git -C /opt/safe-tx-hashes-util rev-parse HEAD)
        if [[ "$actual" != "$PINNED_COMMIT" ]]; then
            echo "[safe-tx-hashes-util] ERROR: commit mismatch (got \`${actual}\`, expected \`${PINNED_COMMIT}\`)!" >&2
            exit 1
        fi

        chmod 555 /opt/safe-tx-hashes-util/safe_hashes.sh
        chown root:root /opt/safe-tx-hashes-util/safe_hashes.sh
        echo "[safe-tx-hashes-util] Installation done ✔."
