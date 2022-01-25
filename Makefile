
certType ?= "root"

# 証明書を生成する
.PHONY: generate
generate:
	bash create-cert.sh $(certType)

# ルート証明書
.PHONY: generate-root
generate-root:
	bash create-cert.sh root

# 中間証明書
.PHONY: generate-intermediate
generate-intermediate:
	bash create-cert.sh intermediate root

# 末端証明書
.PHONY: generate-leaf-for-server
generate-leaf-for-server:
	bash create-cert.sh leafForServer root

# firefoxに持たせるための証明書
.PHONY: generate-leaf-for-client
generate-leaf-for-client:
	bash create-cert.sh leafForClient root

.PHONY: generate-leaf-all
generate-leaf-all:
	make generate-leaf-for-server
	make generate-leaf-for-client

# curlでアクセス
# firefoxと同じ証明書を持たせてcurlで再現
.PHONY: request-api
request-api:
	curl --cert-type P12 \
		--cert ./exportKey/leafForClient.p12:password \
		--cacert ./exportKey/root.x509.pem \
		https://localhost

# サーバー側の動作テスト
# サーバー側でクライアント証明書が送られてこなかった時に400のステータスコードが返ってくるか
.PHONY: request-api-test
request-api-test:
	curl \
		--cacert ./exportKey/root.x509.pem \
		https://localhost
