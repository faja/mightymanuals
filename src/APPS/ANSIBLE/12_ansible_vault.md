---

NOTE: there is [community.sops.sops](https://docs.ansible.com/ansible/latest/collections/community/sops/sops_lookup.html) lookup plugin
as well as [community.sops.load_vars](https://docs.ansible.com/ansible/latest/collections/community/sops/load_vars_module.html) module
~> see [SOPS](./13_sops.md) for more details

---

```sh
mkdir -p group_vars/all
ansible-vault create group_vars/all/vault
# without extension, to not confuse linters and editors
ansible-vault view ${VAULT_FILE}
ansible-vault rekey ${VAULT_FILE}
ansible-vault
```

```sh
ansible-playbook --ask-vault-pass playbook.yaml
ansible-playbook --vault-password-file ~/somefile playbook.yaml
  # if ~/somefile is executable it will be executed and stdout is taken
```
