---

# ssh-keygen

- gen new ssh key, edDSA type
    ```sh
    ssh-keygen -t ed25519 -b 4096 -C 'comment' -f ~/.ssh/id_myawesomenewkey_2024
    ```

- gen public key from private
    ```sh
    ssh-keygen -y -f ~/.ssh/id_myawesomenewkey_2024
    ```

- other
    ```sh
    ssh-keygen -p -f ~/.ssh/id_ed25519 # add/update passphrase of an existing key
    ```

# ssh-keyscan
```
ssh-keygen -R ${SOME_HOSTNAME_FROM_KNOWN_HOSTS}
ssh-keyscan ${SOME_HOSTNAME_FROM_KNOWN_HOSTS} >> ~/.ssh/known_hosts
```

# ~/.ssh/config

### bastion jump

my
```
Host bastion
  User ec2-user
  ForwardAgent yes

Host 172*
  User ec2-user
  ForwardAgent yes
  ProxyCommand ssh ec2-user@bastion -W %h:%p
```

from ansible book
```
Host bastion
  Hostname X.X.X.X
  User ...
  # basically bastion options

Host *.private.cloud
  User ...
  CheckHostIP no
  StrictHostKeyChecking no
  ProxyJump bastion
```
