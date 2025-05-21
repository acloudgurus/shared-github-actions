# echo "TOKEN >>>> $TOKEN"
# curl -k -H "Authorization: Token $TOKEN" \
#     -o /etc/pki/ca-trust/source/anchors/cigna.pem \
#     https://raw.githubusercontent.com/zilvertonz/central-certs/refs/heads/main/cigna.pem
mv /opt/scripts/certs/cigna.pem /etc/pki/ca-trust/source/anchors/ && update-ca-trust

export REQUESTS_CA_BUNDLE="/etc/pki/tls/cert.pem"
export AWS_CA_BUNDLE=$REQUESTS_CA_BUNDLE
export SSL_CERT_FILE=$REQUESTS_CA_BUNDLE


