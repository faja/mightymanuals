# 

```sh
openssl x509 -in c2.crt -noout -text                  # get info about certificate
echo -n | openssl s_client -connect node_address:443  # fetch certificate from remote host

openssl s_client -connect rackerhacker.com:443 -servername rackerhacker.com  # to send SNI use -servername option

openssl dhparam -dsaparam -out dhparams.pem 4098  # generate dhparams
```
