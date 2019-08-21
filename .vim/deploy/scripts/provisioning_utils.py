import string
import random


def random_identifier(prefix):
    return prefix + '-' + ''.join(random.choice(
        string.ascii_lowercase + string.digits) for _ in range(6))


def get_credentials(location):
    with open(location) as credfile:
        return_dict = {}
        for line in credfile:
            (key, val) = line.split("=")
            return_dict[key] = val.rstrip()
        return return_dict
