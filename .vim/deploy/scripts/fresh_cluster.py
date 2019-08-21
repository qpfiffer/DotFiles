import boto.ec2
import boto.s3
import boto.vpc
from time import sleep
from sys import argv
from provisioning_utils import get_credentials
import new_rds
import json


def new_vpc(creds, region, cluster_label):
    print "creating a new VPC"
    cidr_block = "10.0.1.0/24"
    subnet1 = "10.0.1.0/25"
    subnet2 = "10.0.1.128/25"

    conn = boto.vpc.connect_to_region(
        region,
        aws_access_key_id=creds['AWSAccessKeyId'],
        aws_secret_access_key=creds['AWSSecretKey'])

    zones = conn.get_all_zones()
    vpc = conn.create_vpc(cidr_block=cidr_block)
    conn.modify_vpc_attribute(vpc.id,
                              enable_dns_support=True)
    conn.modify_vpc_attribute(vpc.id,
                              enable_dns_hostnames=True)
    gateway = conn.create_internet_gateway()
    conn.attach_internet_gateway(gateway.id, vpc.id)
    route_table = conn.create_route_table(vpc.id)
    conn.create_route(route_table.id, '0.0.0.0/0', gateway.id)
    sg = conn.create_security_group(
        name=cluster_label,
        description=cluster_label,
        vpc_id=vpc.id)
    sg.authorize(ip_protocol='tcp',
                 src_group=sg,
                 from_port=0,
                 to_port=65535)
    sg.authorize(ip_protocol='tcp',
                 from_port=80,
                 to_port=80,
                 cidr_ip="0.0.0.0/0")
    sg.authorize(ip_protocol='tcp',
                 from_port=443,
                 to_port=443,
                 cidr_ip="0.0.0.0/0")
    sg.authorize(ip_protocol='tcp',
                 from_port=22,
                 to_port=22,
                 cidr_ip="0.0.0.0/0")
    subnet1 = conn.create_subnet(vpc.id, subnet1,
                                 availability_zone=zones[0].name)
    subnet2 = conn.create_subnet(vpc.id, subnet2,
                                 availability_zone=zones[1].name)

    conn.associate_route_table(route_table.id, subnet1.id)
    conn.associate_route_table(route_table.id, subnet2.id)

    print "new VPC and ancillary networking infrastructure complete"
    print "vpc id: %s" % vpc.id
    print "sg id: %s" % sg.id
    print "subnets: %s %s" % (subnet1.id, subnet2.id)
    print "gateway: %s" % gateway.id
    print "route table: %s" % route_table.id
    return [vpc, sg, [subnet1.id, subnet2.id], gateway, route_table]


def new_instance(creds, region, ami, key, instance_class,
                 security_group_id, subnet_id):
    print "creating a new EC2 instance"
    ec2conn = boto.ec2.connect_to_region(
        region,
        aws_access_key_id=creds['AWSAccessKeyId'],
        aws_secret_access_key=creds['AWSSecretKey'])

    reservation = ec2conn.run_instances(
        ami,
        key_name=key,
        instance_type=instance_class,
        security_group_ids=[security_group_id],
        subnet_id=subnet_id)
    print "new instance complete"
    return reservation


def instance_pending(conn, instance_id):
        instance = conn.get_only_instances(instance_ids=instance_id)[0]
        if instance.state == 'pending':
            sleep(10.0)
        elif instance.state == 'running':
            return True
        else:
            raise Exception("instance did not survive to maturity")


def allocate_and_associate_elastic_ip(conn, instance_id):
    print "allocating an Elastic IP and associating it with the EC2 instance"
    while True:
        if conn.get_only_instances(
                instance_ids=instance_id)[0].state == 'pending':
            sleep(10.0)
        elif conn.get_only_instances(
                instance_ids=instance_id)[0].state == 'running':
            elastic_ip = conn.allocate_address("vpc")
            elastic_ip.associate(instance_id=instance_id)
            print "EIP allocation and association complete"
            return elastic_ip


def new_s3(cred_location, region, bucket_name):
    print "creating new s3 bucket: %s" % bucket_name
    creds = get_credentials(cred_location)
    s3conn = boto.s3.connect_to_region(
        region,
        aws_access_key_id=creds['AWSAccessKeyId'],
        aws_secret_access_key=creds['AWSSecretKey'])
    s3conn.create_bucket(bucket_name, location=region)
    print "new bucket %s created" % bucket_name


def main(cred_location, region, ami, key, instance_class, cluster_label,
         rds_instance_class, rds_user, rds_password, rds_storage, rds_port,
         rds_engine, cluster_details_file, bucket_name):

    creds = get_credentials(cred_location)

    new_s3(cred_location, region, bucket_name)

    ec2conn = boto.ec2.connect_to_region(
        region,
        aws_access_key_id=creds['AWSAccessKeyId'],
        aws_secret_access_key=creds['AWSSecretKey'])

    vpc, sg, subnet_ids, gateway, route_table = \
        new_vpc(creds, region, cluster_label)

    instance_id = new_instance(
        creds,
        region,
        ami,
        key,
        instance_class,
        sg.id,
        subnet_ids[0]).instances[0].id

    elastic_ip = allocate_and_associate_elastic_ip(ec2conn, instance_id)

    rds_in_provisioning = new_rds.create_and_add_to_sec_groups(
        creds, cluster_label, rds_instance_class, rds_user, rds_password,
        rds_storage, rds_port, rds_engine, rds_user,
        subnet_ids,
        [sg.id],
        region)

    rds = new_rds.rds_details(creds, region, rds_in_provisioning.id)

    cluster_dict = {"instance_ip": elastic_ip.public_ip,
                    "rds_endpoint": rds.endpoint,
                    "rds_id": rds.id,
                    "s3_bucket": bucket_name,
                    "region": region,
                    "vpc_id": vpc.id,
                    "sg_id": sg.id,
                    "subnet_ids": subnet_ids,
                    "instance_id": instance_id,
                    "gateway_id": gateway.id,
                    "elastic_allocation_id": elastic_ip.allocation_id,
                    "elastic_association_id": elastic_ip.association_id,
                    "route_table_id": route_table.id,
                    "cluster_label": cluster_label}

    with open(cluster_details_file, 'w+') as f:
        json.dump(cluster_dict, f)

if __name__ == '__main__':
    cred_location = argv[1]
    region = argv[2]
    ami = argv[3]
    key = argv[4]
    instance_class = argv[5]
    cluster_label = argv[6]
    bucket_name = argv[7]
    rds_instance_class = argv[8]
    rds_user = argv[9]
    rds_password = argv[10]
    rds_storage = argv[11]
    rds_port = argv[12]
    rds_engine = argv[13]
    cluster_details_file = argv[14]

    main(cred_location, region, ami, key, instance_class, cluster_label,
         rds_instance_class, rds_user, rds_password, rds_storage, rds_port,
         rds_engine, cluster_details_file, bucket_name)

    print "AWS cluster created. See %s for cluster details." \
        % cluster_details_file
