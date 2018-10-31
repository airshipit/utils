#!/usr/bin/env bash

set -o pipefail
set -o errexit
set -o xtrace

apt update
apt install -y curl
curl -s localhost:8080/aptly_repo_signing.key | apt-key add -
echo 'deb http://localhost:8889 xenial main' > /etc/apt/sources.list
apt-get update
PACKAGES=${PACKAGES:-accountsservice}
for package in $PACKAGES; do
    apt-cache policy "$package"
    apt-get install -y "$package"
done
