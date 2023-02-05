```sh
nomad agent -dev   # start dev server

###############################
### node/server/ops related ###
nomad server members             # list servers
nomad node status                # list clients
nomad node status ${NODE_ID}     # get node info
nomad agent-info                 # executed on the agent node, gives useful info, like last_log_index etc
nomad operator raft list-peers   # show raft version

#########################
### namespace related ###
nomad namespace list   # list namespaces

###################
### job related ###
nomad job status ${JOB_NAME}                     #
nomad job init -short                            # generate job spec example
nomad job plan file.nomad                        #
nomad job run -check-index ${INDEX} file.nomad   #
nomad job inspect ${JOB_NAME} | grep image       # get image of the running job

#####################
### alloc related ###
nomad alloc status ${ALLOC_ID}                              # get alloc status
nomad alloc logs -f -n 100                    ${ALLOC_ID}   # get alloc/task logs STDOUT
nomad alloc logs -f -n 100 -stderr            ${ALLOC_ID}   # get alloc/task logs STDERR
nomad alloc logs -f -n 100 -task ${TASK_NAME} ${ALLOC_ID}   # get logs for a particular task (for multitask allocs)
```
