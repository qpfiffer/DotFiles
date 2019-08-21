from boto.rds import connect_to_region
from time import sleep


def create_and_add_to_sec_groups(creds, identifier,
                                 instance_class,
                                 master_username,
                                 master_password,
                                 allocated_storage,
                                 port,
                                 engine,
                                 db_name,
                                 subnet_ids,
                                 security_groups,
                                 region):

    conn = connect_to_region(region,
                             aws_access_key_id=creds['AWSAccessKeyId'],
                             aws_secret_access_key=creds['AWSSecretKey'])

    conn.create_db_subnet_group(identifier, identifier, subnet_ids)

    instance = conn.create_dbinstance(
        id=identifier,
        instance_class="db." + instance_class,
        allocated_storage=allocated_storage,
        engine=engine,
        db_name=db_name,
        master_username=master_username,
        master_password=master_password,
        db_subnet_group_name=identifier,
        vpc_security_groups=security_groups,
        port=port)

    print "new RDS instance online"
    return instance


def rds_details(creds, region, id):
    """blocks on RDS actually being available"""
    while True:
        conn = connect_to_region(
            region,
            aws_access_key_id=creds['AWSAccessKeyId'],
            aws_secret_access_key=creds['AWSSecretKey'])
        rds = conn.get_all_dbinstances(instance_id=id)[0]
        if rds.status != 'available':
            print "rds status: %s" % rds.status
            sleep(10.0)
        elif rds.status == 'available':
            return rds
