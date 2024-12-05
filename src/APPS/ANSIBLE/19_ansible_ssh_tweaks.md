---

# tldr
- keep all default values, should be just fine,
- ...but if you really wanna play with some tuning - MEASURE!
- worth giving a try
    ```ini
    [connection]
    pipelining = true
    forks = 10 # use 50 for large prod envs
    [ssh_connection]
    ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s -4 -o PreferredAuthentications=publickey
    ```

---

# pipelining
ansible executes python scripts by pipelining them instead of copying them
- `ansible.ini`
    ```ini
    [connection]
    pipelining = true
    # note, this require `requiretty` setting NOT be set in sudoers config,
    # which is the default, so we should be good there
    ```
- see [connection](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/connection.html)

# parallelism
- connect to more hosts in parallel, defautl **``5**
    ```ini
    [connection]
    forks = 10
    # default 5, on large
    # on large prod environmnets, 50 is common number
    ```

# ssh multiplexing
- ssh multiplexing, is to establish a connection ONCE, keep it open, and re-use
  is for further ssh executions
- to manually enable ssh multiplexing, `~/.ssh/config`:
    ```
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 10m
    # man 5 ssh_config
    ```
- some commands, multiplexing related:
    ```sh
    ssh -O check ${user}@${host} # check if master connection is open
    ssh -O exit ${user}@${host}  # manually stop master connection
    ```
- ansible by default enables multiplexing so no action is needed there,
  but it is possible to tweak it via `[ssh_connection]` section in `ansible.ini`
- see [ssh_connection](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/ssh_connection.html)
  docs for more details

# ssh_args
- is worth to consider adding these two extra arg to speed up ssh connection
  establish time
    ```sh
    -4 -o PreferredAuthentications=publickey
    ```
- but remember that ansible comes with some decent default, and by overwriting it
  you might lose some nice default value if future releases bring some goodies,
  at the time of writing, default:
    ```sh
    -C -o ControlMaster=auto -o ControlPersist=60s
    ```
- so:
    ```
    [ssh_connection]
    ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s -4 -o PreferredAuthentications=publickey

# use modern host key -> ed25519
- use modern host key `ed25519`, generate one and distribute their public key
to all client connecting
- also, if the environment is well controlled, enforce the SAME, and SINGLE,
  algorithm, with such approach there is no negotiation between client and server
  and everything goes smoothly
- `/etc/ssh/sshd_config` (on all hosts):
    ```sh
    HostKey /etc/ssh/ssh_host_ed25519_key
    # remove all other HostKey directives

    # accept only ed25519 clients
    PubkeyAcceptedKeyTypes ssh-ed25519-cert-v01@openssh.com,ssh-ed25519
    ```
