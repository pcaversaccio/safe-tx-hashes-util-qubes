cleanup_packages:
  cmd.run:
    - name: |
        echo "[Cleanup] Removing build dependencies..."
        dnf remove -y git
        dnf clean all
