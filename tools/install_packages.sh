#!/usr/bin/env bash

set -o pipefail
set -o errexit
set -o xtrace

apt update
apt install -y curl
curl -s localhost:8080/aptly_repo_signing.key | apt-key add -
echo 'deb http://localhost:8080 xenial main' > /etc/apt/sources.list
apt-get update
apt-cache policy accountsservice
apt-get install -y accountsservice
