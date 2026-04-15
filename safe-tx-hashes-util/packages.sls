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
        - firefox # Optional GUI browser (remove for terminal-only setup).
