include:
  - safe-tx-hashes-util.vm

provision_template:
  qvm.run:
    - name: safe-tx-hashes-util-template
    - cmd: qubesctl state.apply safe-tx-hashes-util.provision
    - require:
        - qvm: safe-tx-hashes-util-template
