install_foundry:
  cmd.run:
    - shell: /bin/bash
    - env:
        - http_proxy: http://127.0.0.1:8082
        - https_proxy: http://127.0.0.1:8082
    - name: |
        set -Eeuo pipefail

        declare -A HASHES
        HASHES["v1.5.1"]="73640b01bd9ed29fdb4965085099371f8cf0dbbec3e2086cf54564efc4dcfe88" # See https://github.com/foundry-rs/foundry/releases/tag/v1.5.1.

        readonly VERSION="v1.5.1"
        echo "[Foundry] Installing Foundry version \`${VERSION}\`..."

        mkdir -p /opt/foundry

        readonly SHA256="${HASHES[$VERSION]:-}"
        if [[ -z "$SHA256" ]]; then
            echo "[Foundry] ERROR: missing SHA256 for version \`${VERSION}\`!" >&2
            exit 1
        fi

        readonly URL="https://github.com/foundry-rs/foundry/releases/download/${VERSION}/foundry_${VERSION}_linux_amd64.tar.gz"

        readonly TMP_FILE="/tmp/foundry_${VERSION}.tar.gz"
        readonly SRC_DIR="/opt/foundry_src"

        trap 'rm -f "$TMP_FILE"; rm -rf "$SRC_DIR"' EXIT

        echo "[Foundry] Version: \`${VERSION}\`"
        echo "[Foundry] URL    : ${URL}"

        curl --proto "=https" -fL --retry 3 --connect-timeout 10 -o "$TMP_FILE" "$URL"

        echo "[Foundry] Verifying SHA256..."
        echo "${SHA256} ${TMP_FILE}" | sha256sum -c -

        rm -rf "$SRC_DIR"
        mkdir -p "$SRC_DIR"

        tar -xzf "$TMP_FILE" -C "$SRC_DIR"

        REQUIRED=("cast" "chisel")

        for bin in "${REQUIRED[@]}"; do
            [[ -x "$SRC_DIR/$bin" ]] || {
                echo "[Foundry] ERROR: missing required binary \`${bin}\`!" >&2
                exit 1
            }
        done

        readonly COMMIT=$("$SRC_DIR/cast" --version | awk '/Commit SHA:/ {print $3}')

        if [[ -z "$COMMIT" ]]; then
            echo "[Foundry] ERROR: commit SHA resolution failed!" >&2
            exit 1
        fi

        echo "[Foundry] Commit: \`${COMMIT}\`."

        readonly INSTALL_DIR="/opt/foundry/${COMMIT}"
        readonly CURRENT=$(readlink /opt/foundry/current 2>/dev/null || true)

        if [[ "$CURRENT" == "$INSTALL_DIR" ]]; then
            echo "[Foundry] Already installed and active ✔."
            exit 0
        fi

        mkdir -p "$INSTALL_DIR"

        for bin in "${REQUIRED[@]}"; do
            if [[ -f "$SRC_DIR/$bin" ]]; then
                install -m 0755 "$SRC_DIR/$bin" "$INSTALL_DIR/"
                echo "[Foundry] Installed \`$bin\`."
            fi
        done

        ln -sfn "$INSTALL_DIR" /opt/foundry/current

        echo "[Foundry] Active commit: $(readlink /opt/foundry/current)."
        echo "[Foundry] Installation done ✔."

foundry_path_profile:
  file.managed:
    - name: /etc/profile.d/foundry.sh
    - mode: "0644"
    - contents: |
        export PATH=/opt/foundry/current:$PATH
