install_fedora_template:
  cmd.run:
    - name: qubes-dom0-update -y qubes-template-fedora-43-minimal
    - unless: qvm-ls | grep fedora-43-minimal

safe-tx-hashes-util-template:
  qvm.template:
    - present
    - label: red
    - template: fedora-43-minimal
    - require:
        - cmd: install_fedora_template
