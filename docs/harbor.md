
https://goharbor.io/docs/2.5.0/install-config/

gpg --keyserver hkps://keyserver.ubuntu.com --receive-keys 644FF454C0B4115C

# generate a authority certificate
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -sha512 -days 3650 \
    -subj "/C=CN/ST=Shanghai/L=Shanghai/O=registry/OU=UIH/CN=registry.image.local.com" \
    -key ca.key \
    -out ca.crt

# generate a server certificate
openssl genrsa -out registry.image.local.com.key 4096
openssl req -x509 -new -nodes -sha512 -days 3650 \
    -subj "/C=CN/ST=Shanghai/L=Shanghai/O=registry/OU=UIH/CN=registry.image.local.com" \
    -key registry.image.local.com.key \
    -out registry.image.local.com.csr

openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in registry.image.local.com.csr \
    -out registry.image.local.com.crt