---

[age](https://github.com/FiloSottile/age)

```sh
# config
mkdir -p ~/.config/age
chmod 700 ~/.config/age
age-keygen -o ~/.config/age/key.txt


# key based encryption/decryption
age -e -r age1...key1 -o some_file.yaml.age some_file.yaml # encrypt with recipient key
age -d -i path_to_age_private_key some_file.yaml.age       # decrypt with private key


# passphrase based encryption/decryption
age -e -p -o some_file.yaml.age some_file.yaml  # encrypt with passphrase
age -d some_file.yaml.age                       # decryppt passphrase protected file
```

---

see also [sops](./../SOPS/index.md) for some `sops`+`age` combo usage
