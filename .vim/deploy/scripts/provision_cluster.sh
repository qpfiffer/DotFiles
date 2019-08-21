#! /bin/bash -eu

# script takes ordered args ("example"):
# - credential file location ("aws_credentials")
# - environment ("tst")
# - cluster name ("survantjames")
# - bucket name ("console.smartvineyards.net")
# - region ("us-west-2")
# - AWS AMI ("ami-6ac2a85a" - must be valid in the region in question)
# - key ("survantjames")
# - instance class ("m1.small")
# - rds instance class ("t1.micro")
# - rds user ("postgres")
# - rds password ("postgres")
# - rds storage (gb, "5")
# - rds port ("5432")
# - rds engine ("postgres")
# - details_outfile (something.json to capture cluster details)
# - repository location (github.com:survantjames/verdot.git)



# arguments
credential_file=$1
environment_label=$2
cluster_name=$3
bucket_name=$4
region=$5
ami=$6
key_name=$7
instance_class=$8
rds_instance_class=$9
rds_user=${10}
rds_password=${11}
rds_storage=${12}
rds_port=${13}
rds_engine=${14}
details_outfile=${15}
repository_location=${16}

. base.sh

# script globals
provisioning_datafile="cluster_details.txt"

# calculated values
cluster_label="$environment_label-$cluster_name"

# new ec2 instance
make_cluster() {
    python fresh_cluster.py \
        "$credential_file" \
        "$region" \
        "$ami" \
        "$key_name" \
        "$instance_class" \
        "$cluster_label" \
        "$bucket_name" \
        "$rds_instance_class" \
        "$rds_user" \
        "$rds_password" \
        "$rds_storage" \
        "$rds_port" \
        "$rds_engine" \
        "$details_outfile"
}

cleanup() {
    rm $provisioning_datafile
}

get_cluster_detail() {
    cat "$details_outfile" | jq --compact-output ".$1"
}

read_details() {
    rds_id=$(get_cluster_detail "rds_id")
    region=$(get_cluster_detail "region")
    vpc_id=$(get_cluster_detail "vpc_id")
    sg_id=$(get_cluster_detail "sg_id")
    rds_endpoint=$(get_cluster_detail "rds_endpoint[0]")
    rds_port=$(get_cluster_detail "rds_endpoint[1]")
    subnet_ids=$(get_cluster_detail "subnet_ids[]")
    eid=$(get_cluster_detail "elastic_allocation_id")
    gateway_id=$(get_cluster_detail "gateway_id")
    instance_ip=$(get_cluster_detail "instance_ip")
    s3_bucket=$(get_cluster_detail "s3_bucket")
    instance_id=$(get_cluster_detail "instance_id")
    route_table_id=$(get_cluster_detail "route_table_id")
    cluster_label=$(get_cluster_detail "cluster_label")
}

destroy_cluster() {
    python destroy_cluster.py \
        "$rds_id" \
        "$instance_id" \
        "$s3_bucket" \
        "$eid" \
        "$sg_id" \
        "$subnet_ids" \
        "$gateway_id" \
        "$vpc_id" \
        "$route_table_id" \
        "$cluster_label" \
        "$credential_file" \
        "$region"
}

decrypt_and_send_ssl_certs() {
    local CERT_TARBALL=taplister.com.tar.gz
    local HOST=$1

    echo "Decrypting SSL certificates."
    set -e
    if [ ! -f "$CERT_TARBALL" ]; then
        gpg --out $CERT_TARBALL --decrypt $CERT_TARBALL.gpg
    fi
    tar -xf $CERT_TARBALL

    echo "Copying keys."
    scp taplister.com.{crt,csr,key} ubuntu@"$host":'$HOME'
    set +e
}

provision_ec2() {
    local host=$(remove_wrapping_quotes "$1")
    local repo=$(remove_wrapping_quotes "$2")
    local rds_ep=$(remove_wrapping_quotes "$3")
    local rds_port=$(remove_wrapping_quotes "$4")
    local rds_user=$(remove_wrapping_quotes "$5")
    local rds_password=$(remove_wrapping_quotes "$6")
    # We decrypt ssl here because it needs to happen before the provision step,
    # we need access to the local user's GPG keys and everything that happens in
    # provision.sh happens on the target machine.
    # decrypt_and_send_ssl_certs "$host"
    ./provision.sh "$host" "$repo" "$rds_ep" "$rds_port" \
        "$rds_user" "$rds_password" "$bucket_name"
}

deploy_app() {
    local host=$(remove_wrapping_quotes "$instance_ip")
    local rds_user=$(remove_wrapping_quotes "$rds_user")
    local rds_password=$(remove_wrapping_quotes "$rds_password")
    ./deploy.sh "$details_outfile"
}

make_cluster
read_details
provision_ec2 "$instance_ip" "$repository_location" "$rds_endpoint" \
    "$rds_port" "$rds_user" "$rds_password"
deploy_app
#destroy_cluster

echo "AWS provisioning complete."
