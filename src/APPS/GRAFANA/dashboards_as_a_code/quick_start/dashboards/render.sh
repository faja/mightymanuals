#!/bin/bash -

NAME=${1} 
NAME_IN=${1}.jsonnet
NAME_OUT=${1}.json

jsonnet -J vendor -o ${NAME_OUT} ${NAME_IN}
