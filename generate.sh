#!/bin/bash

tempdir=$1

conf=$(cat <<EOF
[req]
distinguished_name = req_distinguished_name
prompt = no


[req_distinguished_name]
C = JP
ST = Tokyo
OU = Test app development
CN = Latona SAP Root CA

[ca]
default_ca = ca_default

[ca_default]
dir = $tempdir
database = \$dir/index.txt
serial = \$dir/serial.txt
default_md = sha256

# 新しく証明書を作るディレクトリ
new_certs_dir = \$dir
default_days = 365
policy = ca_default_policy

[ca_default_policy]
countryName = optional
stateOrProvinceName = optional
organizationName = optional
organizationalUnitName = optional
commonName = optional
emailAddress = optional

[v3_ca]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always

basicConstraints = CA:TRUE, pathlen:0
EOF
)

echo "$conf"
