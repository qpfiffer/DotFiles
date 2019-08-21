#!/bin/bash -ex

# $1 - IP address
# $2 - Branch name, defaults to master

HOST=$1

cat {base,self-sync-keys}.sh | \
    ssh -At "$HOST" bash -s

keys=$(cat authorized_keys)
ssh -At "$HOST" "echo \"$keys\" | sudo -u ubuntu tee /home/ubuntu/.ssh/authorized_keys"
