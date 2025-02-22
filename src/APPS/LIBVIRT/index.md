---

### virsh
```sh
# getting help #################################################################
virsh --help | grep ...
virsh ${COMMAND} --help

# vm ###########################################################################
virsh list --all
DOMAIN_NAME=...

# edit a VM config
virsh edit ${DOMAIN_NAME}

# gracefully stop and remove
virsh shutdown ${DOMAIN_NAME}
virsh undefine ${DOMAIN_NAME} --remove-all-storage

# force remove
virsh destroy ${DOMAIN_NAME}

# volumes ######################################################################
virsh pool-list
virsh vol-list --pool ${POOL_NAME}
virsh vol-clone --pool ${POOL_NAME} ${SRC_IMAGE} ${DST_IMAGE}
  # i think it works for RAW type only
```

### misc
#### how to vnc to a vm
```sh

# ssh to host were VM is runing
ps auxww | grep ${VM_NAME} | grep --color vnc
# should print something like -vnc 0.0.0.0:0
# important part is :${NUMBER} as it mapps to port vnc for this VM listens on
# :0 = 5900
# :1 = 5901
# ..etc

# establish ssh tunnel to the right port, eg:
ssh -L 5901:127.0.0.1:5901 ${HOST_NAME}

# open vnciewer and connect to 127.0.0.1:5901
```

#### how to increase memory
```sh
# first stop the VM
virsh setmaxmem ${DOMAIN_NAME} 16G --config
virsh setmem    ${DOMAIN_NAME} 16G --config
virsh start     ${DOMAIN_NAME}
```
