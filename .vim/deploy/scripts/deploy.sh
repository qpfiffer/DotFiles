#! /bin/bash -e

# $1 - cluster details file
. base.sh

CLUSTER_DETAILS=$1
ref=$(git rev-parse HEAD)

read_details $CLUSTER_DETAILS

# compile jar file
lein uberjar

# scp jar file to remote host
pushd ../../target
scp acuitas-standalone.jar "ubuntu@$instance_ip:/app/$ref.jar"
popd

# ref, dbhost, dbport, dbuser, dbpass
cat {base,self-deploy,test-deploy}.sh | \
    ssh -At "ubuntu@$instance_ip" bash -s \
        "$ref.jar" \
        "$rds_endpoint" "$rds_port" \
        postgres postgres
