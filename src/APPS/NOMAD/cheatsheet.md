```
nomad agent -dev                    # start dev server

###

nomad server members              # list servers
nomad node status                 # list clients
nomad agent-info                  # executed on the agent node, gives useful info, like last_log_index etc

###

nomad job status ${JOB_NAME}      # get job status, and some useful info, eg: compute node allocations are running
nomad node status ${NODE_ID}      # get node info
nomad namespace list              # list namespaces

nomad alloc status <alloc_id>                        # get alloc status
nomad alloc logs -f -n 100         <alloc_id> [task] # get alloc/task logs STDOUT
nomad alloc logs -f -n 100 -stderr <alloc_id> [task] # get alloc/task logs STDERR

nomad job init -short             # generate job spec example

nomad job plan file.nomad
nomad job run -check-index XXX file.nomad

### 

nomad operator raft list-peers    # show raft version
```
