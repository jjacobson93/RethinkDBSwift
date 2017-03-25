#!/bin/bash
# Generate the root
openssl genrsa -out ca.key 2048 && \
openssl req -new -x509 -days 3650 -key ca.key -sha256 -extensions v3_ca -out ca.pem && \

# Generate the domain key
openssl genrsa -out key.pem 2048 && \

# Generate the certificate signing request
openssl req -sha256 -new -key key.pem -out rethink.csr  && \

# Sign the request with your root key
openssl x509 -sha256 -req -in rethink.csr -CA ca.pem -CAkey ca.key -out cert.pem -days 3650  && \

# Generate pkcs12 certificate chain
openssl pkcs12 -export -out cert.pfx -inkey key.pem -in cert.pem && \

# remove the csr
rm rethink.csr