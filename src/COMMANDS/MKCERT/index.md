<span style="color:#ff4d94">**mkcert**</span> - simple tool (in go) to create dev certs

[mkcert github](https://github.com/FiloSottile/mkcert)

```sh
# install arch
pacman -S mkcert

# usage
mkcert -CAROOT     # print CA cert location/path
mkcert test.local  # generate cert (public key) and private key for test.local
                   # it generates two files:
                   #   - test.local.pem
                   #   - test.local-key.pem
```
