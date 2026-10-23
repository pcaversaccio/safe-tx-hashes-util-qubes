install_fedora_template:
  cmd.run:
    - name: qubes-dom0-update -y qubes-template-fedora-44-minimal
    - unless: qvm-check fedora-44-minimal

safe-tx-hashes-util-template:
  qvm.clone:
    - name: safe-tx-hashes-util-template
    - source: fedora-44-minimal
    - label: red
    - require:
        - cmd: install_fedora_template
