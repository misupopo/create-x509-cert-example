#!/bin/bash

tempdir=$1
cert_type=$2

if [ "$cert_type" == "root" ]; then
certTypeConstraints="critical, CA:TRUE, pathlen:1"
elif [ "$cert_type" == "intermediate" ]; then
certTypeConstraints="critical, CA:TRUE, pathlen:0"
else
certTypeConstraints="critical, CA:FALSE"
fi

if [ "$cert_type" == "leafForServer" ]; then
handleSubjectAltName="subjectAltName = DNS:localhost"
elif [ "$cert_type" == "leafForClient" ]; then
handleSubjectAltName="subjectAltName = DNS:authorized-firefox.example.com"
else
handleSubjectAltName=""
fi

# confの中身
conf=$(cat <<EOF

# openssl req
[req]
distinguished_name = req_for_${cert_type}
prompt = no

# ルート証明書
[req_for_root]
C = JP
ST = Tokyo
OU = System Development
# ルート認証局
CN = Root CA

# 中間証明書
[req_for_intermediate]
C = JP
ST = Tokyo
OU = System Development
# Certificate Authority
# 認証局のこと
# 中間認証局
CN = Intermediate CA

# 末端証明書
[req_for_leafForServer]
# 末端証明書のCNは基本的にはドメイン
CN = localhost

[req_for_leafForClient]
# 末端証明書のCNは基本的にはドメイン
CN = authorized-firefox.example.com

# openssl ca
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

# openssl -extensions v3_ca
[v3_ca]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always
# critical: この証明書を受け取ったソフトウェアで、この属性を解釈できない場合、無視してはならない (エラーで落とす)
keyUsage = critical, digitalSignature, keyCertSign, cRLSign
extendedKeyUsage = clientAuth, serverAuth

# ルート CA:TRUE, pathlen:1
# 中間 CA:TRUE, pathlen:0
# 末端 CA:FALSE
basicConstraints=${certTypeConstraints}

# 末端証明書のみ: ドメイン名をここにもう一度記載
${handleSubjectAltName}

EOF
)

echo "$conf"
