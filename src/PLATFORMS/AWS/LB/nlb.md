---

# security gorups

I always wonder, if we have different port for traffic and for health checks
do we have to open traffic port from private address/security group of NLB?

```sh
-------                     ------------
|     |    health check     |          |
|     | ------------------> :1937      |
| NLB |                     |      EC2 |
|     |    normal traffic   |          |
|     | ------------------> :5002      |
|     |                     |          |
-------                     ------------
```

And the asnwer is you **DO NOT** have to open traffic port from load balancers, only health check port.
The security group should look like:

port|source
----|-
1937|NLB
5002|whoever needs to access the app
