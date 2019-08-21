#!/bin/bash

. base.sh
CI_DETAILS=$1

host=$(cleaned_cluster_detail $CI_DETAILS "ci_ip")

cat {base,self_provision_ci}.sh | \
    ssh -o StrictHostKeyChecking=no \
        -At ubuntu@"$host"
