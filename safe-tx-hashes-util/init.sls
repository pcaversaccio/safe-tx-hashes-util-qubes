include:
  - safe-tx-hashes-util.vm

provision_template:
  cmd.run:
    - name: qubesctl --skip-dom0 --targets=safe-tx-hashes-util-template state.apply safe-tx-hashes-util.provision
    - require:
        - qvm: safe-tx-hashes-util-template
