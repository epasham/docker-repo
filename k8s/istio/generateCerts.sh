#!/bin/bash
set -ex
# If a command fails, set -e will make the whole script exit, instead of resuming on the next line
# set -x	Prints the statements after interpreting metacharacters and variables

WD=$(dirname $0)
WD=$(cd $WD; pwd)
mkdir -p "${WD}/certs"

cat << EOF > ca.cfg
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
C = SE
ST = VGB
L = GOTHENBURG
O = Istio
CN = Istio CA

[v3_req]
keyUsage = keyCertSign
basicConstraints = CA:TRUE
subjectAltName = @alt_names

[alt_names]
DNS.1 = ca.istio.io
EOF

echo '[ INFO ] Generate key and certificate for root CA'
openssl req -newkey rsa:2048 -nodes -keyout root-key.pem -x509 -days 3650 -out root-cert.pem <<EOF
SE
VGB
GOTHENBURG
Istio
Test
Root CA
testrootca@istio.io
EOF

echo '[ INFO ] Generate private key for Istio CA'
openssl genrsa -out ca-key.pem 2048

echo '[ INFO ] Generate CSR for Istio CA.'
openssl req -new -key ca-key.pem -out ca-cert.csr -config ca.cfg -batch -sha256

echo '[ INFO ] Sign the certificate for Istio CA.'
openssl x509 -req -days 1460 -in ca-cert.csr -sha256 -CA root-cert.pem \
 -CAkey root-key.pem -CAcreateserial -out ca-cert.pem -extensions v3_req -extfile ca.cfg

rm *csr
rm *srl
rm ca.cfg

echo '[ INFO ] Generate cert chain file.'
cp ca-cert.pem cert-chain.pem

mv *.pem $WD/certs

echo "[ INFO ] $0 Script is complete"
