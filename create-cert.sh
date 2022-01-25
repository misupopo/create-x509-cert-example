#!/bin/bash

# 証明書タイプ
cert_type=$1

# 親の証明書タイプ
parent_cert_type=$2

# 鍵ファイル名
key_name=$cert_type

# 鍵長 (ビット数)
key_length=2048

# 発効日時（年月日時分Z）
# UTC形式
start_date=20220101090000Z

# 失効日時
end_date=20310101090000Z

# 出力される証明書のディレクトリ
export_directory="./exportKey"

# CA 用テンポラリディレクトリの作成
tempdir=$(mktemp -d)

config=$(bash ./generate.sh "$tempdir" "$cert_type")

# キーペアの作成 (PKCS #8 PEM)
openssl genpkey -algorithm RSA \
	-pkeyopt "rsa_keygen_bits:$key_length" \
	-pkeyopt rsa_keygen_pubexp:65537 \
	-out "$export_directory/$key_name.key"

# CA として振る舞うためのダミーファイル作成
touch "$tempdir/index.txt"
openssl rand -hex 16 > "$tempdir/serial.txt"

if [ "$parent_cert_type" ]; then
  # 中間以下の生成例
  # keyfileは親の物 例：intermediate=root、leaf=intermediate
  # certも親の物 例：intermediate=root、leaf=intermediate
  openssl req -new -key "$export_directory/$key_name.key" -config <(echo "$config") \
  | openssl ca -batch -config <(echo "$config") \
    -keyfile "$export_directory/$parent_cert_type.key" -cert "$export_directory/$parent_cert_type.x509.pem" \
    -startdate "$start_date" -enddate "$end_date" \
    -extensions v3_ca \
    -in /dev/stdin \
    -notext -out "$export_directory/$key_name.x509.pem"
else
  # selfsignはルート証明書のみである場合
  openssl req -new -key "$export_directory/$key_name.key" -config <(echo "$config") \
  | openssl ca -batch -config <(echo "$config") \
  	-selfsign -keyfile "$export_directory/$key_name.key" \
  	-startdate "$start_date" -enddate "$end_date" \
  	-extensions v3_ca \
  	-in /dev/stdin \
  	-notext -out "$export_directory/$key_name.x509.pem"
fi

if [ "$cert_type" == "leafForClient" ]; then
  # PKCS#12 形式に変換
  # firefoxに持たせる用の証明書と秘密鍵を結合したもの
  openssl pkcs12 -export \
  	-passout "pass:password" \
  	-in "$export_directory/leafForClient.x509.pem" -inkey "$export_directory/leafForClient.key" \
  	-out "$export_directory/leafForClient.p12"
fi

# テンポラリディレクトリの削除
rm -rf "$tempdir"
