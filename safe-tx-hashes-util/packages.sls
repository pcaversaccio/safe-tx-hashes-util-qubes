install_packages:
  pkg.installed:
    - pkgs:
        - bash
        - coreutils
        - curl
        - jq
        - ca-certificates
        - qubes-core-agent-networking
        - qubes-core-agent-network-manager
        - git
        - xorg-x11-xauth
        - xclip
        - xsel
        - firefox # Optional GUI browser (remove for a terminal-only setup).

# After provisioning, emit the installed versions of key tools to a persistent
# log for auditability. This does _not_ pin versions (Fedora's signed repos are
# the trust anchor for system packages), but it records exactly what was installed.
record_package_versions:
  cmd.run:
    - name: |
        set -Eeuo pipefail
        LOG=/var/log/safe-tx-hashes-util-versions.log
        {
            echo "=== Provisioned: $(date -u --iso-8601=seconds) ==="
            echo "jq      : $(jq --version)"
            echo "curl    : $(curl --version | head -1)"
            echo "bash    : $(bash --version | head -1)"
            echo "git     : $(git --version)"
        } | tee -a "$LOG"
        echo "[Packages] Version log written to $LOG"
    - require:
        - pkg: install_packages
