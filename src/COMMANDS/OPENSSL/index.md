#

```sh
openssl x509 -in c2.crt -noout -text                  # get info about certificate
echo -n | openssl s_client -connect node_address:443  # fetch certificate from remote host

openssl s_client -connect ${HOST}:${PORT} -servername ${SNI} -showcerts  # to send SNI use -servername option

openssl dhparam -dsaparam -out dhparams.pem 4098  # generate dhparams

openssl ec -in client.key -noout -text  # get info about `EC PRIVATE KEY` key type

###############################################################################
# check if cert matches private key
openssl x509 -noout -modulus -in cert.pem | openssl md5
openssl rsa  -noout -modulus -in key.pem  | openssl md5
```
