import os
import string
import random

from g import DEFAULT_UID, DEFAULT_GID


# To meet security requirement
# By default it will change file mode to 0600, and make the owner of the file to 10000:10000
def mark_file(path, mode=0o600, uid=DEFAULT_UID, gid=DEFAULT_GID):
    if mode > 0:
        os.chmod(path, mode)
    if uid > 0 and gid > 0:
        os.chown(path, uid, gid)


def validate(conf, **kwargs):
    # Protocol validate
    protocol = conf.get("configuration", "ui_url_protocol")
    if protocol != "https" and kwargs.get('notary_mode'):
        raise Exception(
            "Error: the protocol must be https when Harbor is deployed with Notary")
    if protocol == "https":
        if not conf.has_option("configuration", "ssl_cert"):
            raise Exception(
                "Error: The protocol is https but attribute ssl_cert is not set")
        cert_path = conf.get("configuration", "ssl_cert")
        if not os.path.isfile(cert_path):
            raise Exception(
                "Error: The path for certificate: %s is invalid" % cert_path)
        if not conf.has_option("configuration", "ssl_cert_key"):
            raise Exception(
                "Error: The protocol is https but attribute ssl_cert_key is not set")
        cert_key_path = conf.get("configuration", "ssl_cert_key")
        if not os.path.isfile(cert_key_path):
            raise Exception(
                "Error: The path for certificate key: %s is invalid" % cert_key_path)

    # Storage validate
    valid_storage_drivers = ["filesystem",
                             "azure", "gcs", "s3", "swift", "oss"]
    storage_provider_name = conf.get(
        "configuration", "registry_storage_provider_name").strip()
    if storage_provider_name not in valid_storage_drivers:
        raise Exception("Error: storage driver %s is not supported, only the following ones are supported: %s" % (
            storage_provider_name, ",".join(valid_storage_drivers)))

    storage_provider_config = conf.get(
        "configuration", "registry_storage_provider_config").strip()
    if storage_provider_name != "filesystem":
        if storage_provider_config == "":
            raise Exception(
                "Error: no provider configurations are provided for provider %s" % storage_provider_name)

    # Redis validate
    redis_host = conf.get("configuration", "redis_host")
    if redis_host is None or len(redis_host) < 1:
        raise Exception(
            "Error: redis_host in harbor.cfg needs to point to an endpoint of Redis server or cluster.")

    redis_port = conf.get("configuration", "redis_port")
    if len(redis_port) < 1:
        raise Exception(
            "Error: redis_port in harbor.cfg needs to point to the port of Redis server or cluster.")

    redis_db_index = conf.get("configuration", "redis_db_index").strip()
    if len(redis_db_index.split(",")) != 3:
        raise Exception(
            "Error invalid value for redis_db_index: %s. please set it as 1,2,3" % redis_db_index)

def validate_crt_subj(dirty_subj):
    subj_list = [item for item in dirty_subj.strip().split("/") \
        if len(item.split("=")) == 2 and len(item.split("=")[1]) > 0]
    return "/" + "/".join(subj_list)


def generate_random_string(length):
    return ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(length))


def prepare_config_dir(root, *name):
    absolute_path = os.path.join(root, *name)
    if not os.path.exists(absolute_path):
        os.makedirs(absolute_path)
    return absolute_path


def delfile(src):
    if os.path.isfile(src):
        try:
            os.remove(src)
            print("Clearing the configuration file: %s" % src)
        except Exception as e:
            print(e)
    elif os.path.isdir(src):
        for item in os.listdir(src):
            itemsrc = os.path.join(src, item)
            delfile(itemsrc)