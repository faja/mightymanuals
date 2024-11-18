# vagrant playground

- install ansible and vagrant
- `Vagrantfile`
    ```ruby
    Vagrant.configure("2") do |config|
      config.vm.box = "debian/bookworm64"
      NodeCount = 3
      (1..NodeCount).each do |i|
        config.vm.define "node#{i}" do |node|
          node.vm.hostname = "node#{i}.local"
          node.vm.network "private_network", ip: "192.168.59.10#{i}"
          node.vm.provider "virtualbox" do |vb|
            vb.name = "node#{i}.local"
            vb.memory = 1024
            vb.cpus = 1
          end
        end
      end
    end
    ```

- `ansible.cfg`
    ```toml
    [defaults]
    nocows = true
    inventory=./inventory.yaml
    stdout_callback = yaml
    ```

- `inventory.yaml`
    ```yaml
    ---
    ungrouped:
      hosts:
        192.168.59.101:
          ansible_ssh_private_key_file: .vagrant/machines/node1/virtualbox/private_key
        192.168.59.102:
          ansible_ssh_private_key_file: .vagrant/machines/node2/virtualbox/private_key
        192.168.59.103:
          ansible_ssh_private_key_file: .vagrant/machines/node3/virtualbox/private_key
      vars:
        ansible_user: vagrant
    ```

- `playbook.yaml`
    ```yaml
    ---
    - name: my firsy play
      hosts: all
    ```

- run ansible
    ```sh
    ansible all --list-hosts        # to test the inventory
    ansible all -m ping             # to test connectivity
    ansible-playbook playbook.yaml  # to run the very first playbook
    ```

# my prod setup
```
mkdir ${ANSIBLE_PROJECT} && cd ${ANSIBLE_PROJECT}
mkdir inventory
touch inventory/inventory.yaml
touch ansible.cfg
```
