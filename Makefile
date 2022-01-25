
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
.PHONY: generate-leaf
generate-leaf:
	bash create-cert.sh leaf root
