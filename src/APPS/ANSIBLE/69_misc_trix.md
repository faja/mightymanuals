---

# use role but refer files from playbook dir

```yaml
- name: Install ssh key
  ansible.builtin.copy:
    src: "{{ playbook_dir }}/files/users/{{ item }}/id_rsa"
    desc: /home/{{ item }}/.ssh/id_rsa
  with_itesm: "{{ users_bot_users }}"
```
