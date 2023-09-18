# Make a yaml file for the vault cert secret to be used by the k8s cluster
import yaml
from base64 import b64encode
import sys


fileout = sys.argv[1]


# get bash64 encoded cert from the crt file
def get_cert():
    with open("crt", "rb") as f:
        cert = f.read()
        b64_cert = b64encode(cert).decode("utf-8")
        # remove the new line character
        b64_cert = b64_cert.replace("\n", "")
    return b64_cert


# get bash64 encoded key from the key file
def get_key():
    with open("key", "rb") as f:
        key = f.read()
        b64_key = b64encode(key).decode("utf-8")
        b64_key = b64_key.replace("\n", "")
    return b64_key

# make the yaml file


def make_yaml():
    '''
    ---
    apiVersion: v1
    kind: Secret
    metadata:
        name: vault-tls-secret
    type: Opaque
    data:
        vault.pem: <CERT-BASE64>
        vault-key.pem: <KEY-BASE64>
    '''
    cert = get_cert()
    key = get_key()

    yaml_dict = {
        "apiVersion": "v1",
        "kind": "Secret",
        "metadata": {
            "name": "vault-tls-secret"
        },
        "type": "Opaque",
        "data": {
            "vault.pem": cert,
            "vault-key.pem": key
        }
    }

    with open(fileout, "w") as f:
        f.write("---\n")
        yaml.dump(yaml_dict, f)

    return


if __name__ == "__main__":
    make_yaml()
