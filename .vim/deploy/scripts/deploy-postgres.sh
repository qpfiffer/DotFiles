#! /bin/bash -e

# $1 - IP address

HOST=$1

cat {base,self-deploy-postgres,test-deploy-postgres}.sh | \
    ssh -At "$HOST" bash -s \
    $@
