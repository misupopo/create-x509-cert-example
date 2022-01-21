#!/bin/bash

# 鍵ファイル名
key_name=android

# 鍵長 (ビット数)
key_length=2048

# 発効日時
start_date=20220101090000Z

# 失効日時
end_date=20310101090000Z

# 出力される証明書のディレクトリ
export_directory="./exportKey"

# CA 用テンポラリディレクトリの作成
tempdir=$(mktemp -d)

#config=$(cat <<EOF
#[req]
#distinguished_name = req_distinguished_name
#prompt = no
#
#
#[req_distinguished_name]
#C = JP
#ST = Tokyo
#OU = Test app development
#CN = Latona SAP Root CA
#
#[ca]
#default_ca = ca_default
#
#[ca_default]
#dir = $tempdir
#database = \$dir/index.txt
#serial = \$dir/serial.txt
#default_md = sha256
## 新しく証明書を作るディレクトリ
#new_certs_dir = \$dir
#default_days = 365
#policy = ca_default_policy
#
#[ca_default_policy]
#countryName = optional
#stateOrProvinceName = optional
#organizationName = optional
#organizationalUnitName = optional
#commonName = optional
#emailAddress = optional
#
#[v3_ca]
#subjectKeyIdentifier = hash
#authorityKeyIdentifier = keyid:always
##
#basicConstraints = CA:TRUE, pathlen:0
#EOF
#)

config=$(bash ./generate.sh "$tempdir")

# キーペアの作成 (PKCS #8 PEM)
openssl genpkey -algorithm RSA \
	-pkeyopt "rsa_keygen_bits:$key_length" \
	-pkeyopt rsa_keygen_pubexp:65537 \
	-out "$export_directory/$key_name.key"

# CA として振る舞うためのダミーファイル作成
touch "$tempdir/index.txt"
openssl rand -hex 16 > "$tempdir/serial.txt"

# オレオレ証明書の作成
openssl req -new -key "$export_directory/$key_name.key" -config <(echo "$config") \
| openssl ca -batch -config <(echo "$config") \
	-selfsign -keyfile "$export_directory/$key_name.key" \
	-startdate "$start_date" -enddate "$end_date" \
	-extensions v3_ca \
	-in /dev/stdin \
	-notext -out "$export_directory/$key_name.x509.pem"

# テンポラリディレクトリの削除
rm -rf "$tempdir"
