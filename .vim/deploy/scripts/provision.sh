#! /bin/bash -e

# $1 - IP address

HOST=$1
REPO=$2
RDS_HOST=$3
RDS_PORT=$4
RDS_USER=$5
RDS_PASS=$6

cat {base,self-provision,test-provisioning}.sh | \
    ssh -o StrictHostKeyChecking=no \
        -At "ubuntu@$HOST" bash -s \
        "$RDS_HOST" "$RDS_PORT" "$RDS_USER" "$RDS_PASS"
