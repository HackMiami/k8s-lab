#!/bin/bash
openssl genrsa -out key 2048
# cat key | base64 -w 0
# echo '\n'

openssl req -config cert.conf -key key -new -out csr
# cat csr
# echo '\n'

openssl req -key key -new -days 3650 -nodes -x509 -out crt -config cert.conf
# cat crt | base64 -w 0
# echo '\n'

# echo '\nDomains:\n'
# cat cert.conf | grep DNS | sed 's/DNS.*\s=\s//'
