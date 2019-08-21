from sys import argv
from provisioning_utils import get_credentials
from boto import rds, s3, ec2, vpc
from time import sleep


def destroy_s3(creds, region, bucketname):
    print "deleting S3 bucket"
    conn = s3.connect_to_region(
        region,
        aws_access_key_id=creds['AWSAccessKeyId'],
        aws_secret_access_key=creds['AWSSecretKey'])
    conn.delete_bucket(bucketname)
    print "S3 bucket deleted"


def destroy_ec2(creds, region, s3_id):
    print "terminating EC2 instance"
    conn = ec2.connect_to_region(
        region,
        aws_access_key_id=creds['AWSAccessKeyId'],
        aws_secret_access_key=creds['AWSSecretKey'])
    conn.terminate_instances(instance_ids=[s3_id])
    print "EC2 instance terminated"


def destroy_rds(creds, region, rds_id):
    print "tearing down RDS"
    conn = rds.connect_to_region(
        region,
        aws_access_key_id=creds['AWSAccessKeyId'],
        aws_secret_access_key=creds['AWSSecretKey'])
    conn.delete_dbinstance(rds_id, skip_final_snapshot=True)
    print "rds deleted"


def delete_db_subnet_group(creds, region, identifier):
    print "deleting db subnet groups"
    while True:
        conn = rds.connect_to_region(
            region,
            aws_access_key_id=creds['AWSAccessKeyId'],
            aws_secret_access_key=creds['AWSSecretKey'])
        try:
            conn.delete_db_subnet_group(identifier)
            print "db subnet groups deleted"
            break
        except:
            # wait for AWS to catch up
            sleep(5.0)


def release_elastic_ip(creds, region, allocation_id):
    print "releasing Elastic IP address"
    conn = ec2.connect_to_region(
        region,
        aws_access_key_id=creds['AWSAccessKeyId'],
        aws_secret_access_key=creds['AWSSecretKey'])
    while True:
        try:
            conn.release_address(allocation_id=allocation_id)
            print "EIP released"
            break
        except:
            sleep(5.0)


def destroy_vpc(creds, region, vpc_id):
    print "deleting VPC"
    conn = vpc.connect_to_region(
        region,
        aws_access_key_id=creds['AWSAccessKeyId'],
        aws_secret_access_key=creds['AWSSecretKey'])
    conn.delete_vpc(vpc_id)
    print "VPC deleted"


def destroy_security_groups(creds, region, security_group_ids):
    print "deleting security groups"
    conn = ec2.connect_to_region(
        region,
        aws_access_key_id=creds['AWSAccessKeyId'],
        aws_secret_access_key=creds['AWSSecretKey'])
    for id in security_group_ids.split():
        conn.delete_security_group(group_id=id)
    print "security groups removed"


def destroy_subnets(creds, region, subnet_ids):
    print "deleting subnets"
    conn = vpc.connect_to_region(
        region,
        aws_access_key_id=creds['AWSAccessKeyId'],
        aws_secret_access_key=creds['AWSSecretKey'])
    for id in subnet_ids.split():
        conn.delete_subnet(subnet_id=id)
    print "subnets deleted"


def destroy_gateway(creds, region, gateway_id, vpc_id):
    print "detatching internet gateway"
    conn = vpc.connect_to_region(
        region,
        aws_access_key_id=creds['AWSAccessKeyId'],
        aws_secret_access_key=creds['AWSSecretKey'])
    conn.detach_internet_gateway(internet_gateway_id=gateway_id,
                                 vpc_id=vpc_id)
    conn.delete_internet_gateway(
        internet_gateway_id=gateway_id)
    print "internet gateway detached"


def delete_route_table(creds, region, route_table_id):
    conn = vpc.connect_to_region(
        region,
        aws_access_key_id=creds['AWSAccessKeyId'],
        aws_secret_access_key=creds['AWSSecretKey'])
    conn.delete_route_table(route_table_id)


def main(rds_id, ec2_id, vpc_id, s3_bucket, elastic_allocation_id,
         security_group_ids, subnet_ids, gateway_id,
         cred_location, route_table_id, region, cluster_label):
    creds = get_credentials(cred_location)
    destroy_s3(creds, region, s3_bucket)
    destroy_ec2(creds, region, ec2_id)
    destroy_rds(creds, region, rds_id)
    release_elastic_ip(creds, region, elastic_allocation_id)
    destroy_gateway(creds, region, gateway_id, vpc_id)
    delete_db_subnet_group(creds, region, rds_id)
    destroy_subnets(creds, region, subnet_ids)
    destroy_security_groups(creds, region, security_group_ids)
    delete_route_table(creds, region, route_table_id)
    destroy_vpc(creds, region, vpc_id)


if __name__ == '__main__':
    print argv
    rds_id = argv[1].replace('"', '')
    ec2_id = argv[2].replace('"', '')
    s3_bucket = argv[3].replace('"', '')
    elastic_allocation_id = argv[4].replace('"', '')
    security_group_ids = argv[5].replace('"', '')
    subnet_ids = argv[6].replace('"', '')
    gateway_id = argv[7].replace('"', '')
    vpc_id = argv[8].replace('"', '')
    route_table_id = argv[9].replace('"', '')
    cluster_label = argv[10].replace('"', '')
    cred_location = argv[11].replace('"', '')
    region = argv[12].replace('"', '')
    main(rds_id, ec2_id, vpc_id, s3_bucket, elastic_allocation_id,
         security_group_ids, subnet_ids, gateway_id,
         cred_location, route_table_id, region, cluster_label)
