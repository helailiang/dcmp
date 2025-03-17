#!/bin/bash
set -e

# ================== 目录结构初始化 ==================
echo "初始化目录结构..."
mkdir -p ca/root/{certs,private,crl} ca/intermediate/{certs,private,csr}
chmod 700 ca/root/private ca/intermediate/private
cp /dev/null ca/root/index.txt
echo 1000 > ca/root/serial

# ================== 生成根证书 ==================
cat > ca/root/root.cnf <<EOF
[ req ]
distinguished_name = req_distinguished_name
prompt = no
x509_extensions = v3_ca

[ req_distinguished_name ]
C = CN
ST = Beijing
L = Beijing
O = MyRoot CA
OU = Security
CN = MyRoot CA

[ v3_ca ]
basicConstraints = critical,CA:TRUE,pathlen:2
keyUsage = critical,keyCertSign,cRLSign
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
EOF

echo "生成根CA密钥..."
openssl ecparam -name prime256v1 -genkey -out ca/root/private/root.key

echo "生成自签根证书..."
openssl req -x509 -new -key ca/root/private/root.key \
	  -out ca/root/certs/root.crt -config ca/root/root.cnf -days 3650

# ================== 生成中间证书 ==================
cat > ca/intermediate/intermediate.cnf <<EOF
[ req ]
distinguished_name = req_distinguished_name
prompt = no

[ req_distinguished_name ]
C = CN
ST = Beijing
L = Beijing
O = MyIntermediate CA
OU = Security
CN = MyIntermediate CA

[ v3_intermediate_ca ]
basicConstraints = critical,CA:TRUE,pathlen:1
keyUsage = critical,keyCertSign,cRLSign
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
EOF

echo "生成中间CA密钥..."
openssl ecparam -name prime256v1 -genkey -out ca/intermediate/private/intermediate.key

echo "生成中间CA CSR..."
openssl req -new -key ca/intermediate/private/intermediate.key \
	  -out ca/intermediate/csr/intermediate.csr -config ca/intermediate/intermediate.cnf

echo "用根CA签发中间证书..."
openssl x509 -req -in ca/intermediate/csr/intermediate.csr \
	  -CA ca/root/certs/root.crt -CAkey ca/root/private/root.key -CAcreateserial \
	    -out ca/intermediate/certs/intermediate.crt -days 730 \
	      -extfile ca/intermediate/intermediate.cnf -extensions v3_intermediate_ca

# ================== 证书链处理 ==================
echo "构建证书链..."
cp ca/root/certs/root.crt ca/intermediate/certs/
cat  ca/intermediate/certs/intermediate.crt ca/root/certs/root.crt> ca/intermediate/certs/chain.crt

# ================== 验证操作 ==================
echo "验证证书链:"
openssl verify -CAfile ca/root/certs/root.crt ca/intermediate/certs/intermediate.crt

echo "证书层级结构:"
openssl x509 -in ca/root/certs/root.crt -noout -text | grep -A1 "X509v3 Basic Constraints"
openssl x509 -in ca/intermediate/certs/intermediate.crt -noout -text | grep -A1 "X509v3 Basic Constraints"

echo "操作完成！证书文件位置:"
echo "根证书: ca/root/certs/root.crt"
echo "中间证书: ca/intermediate/certs/intermediate.crt"
echo "证书链: ca/intermediate/certs/chain.crt"
