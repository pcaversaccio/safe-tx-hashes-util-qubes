install_fedora_template:
  cmd.run:
    - name: qubes-dom0-update -y qubes-template-fedora-43-minimal
    - unless: qvm-check fedora-43-minimal

safe-tx-hashes-util-template:
  qvm.clone:
    - name: safe-tx-hashes-util-template
    - source: fedora-43-minimal
    - label: red
    - require:
        - cmd: install_fedora_template
