---

# ssh-keygen

- gen new ssh key, edDSA type
    ```sh
    ssh-keygen -t ed25519 -b 4096 -f ~/.ssh/id_myawesomenewkey_2024
    ```

- gen public key from private
    ```sh
    ssh-keygen -y -f ~/.ssh/id_myawesomenewkey_2024
    ```
