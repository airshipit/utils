#! /usr/bin/env bash

# Copyright 2018 Artem B. Smirnov
# Copyright 2018 Jon Azpiazu
# Copyright 2016 Bryan J. Hong
# Licensed under the Apache License, Version 2.0

set -o xtrace

if [[ ! -f /root/.gnupg/gpg.conf ]]; then
  /opt/gpg.conf.sh
fi

# If the repository GPG keypair doesn't exist, create it.
if [[ ! -f /opt/aptly/aptly.sec ]] || [[ ! -f /opt/aptly/aptly.pub ]]; then
  echo "Generating new gpg keys"
  cp -a /dev/urandom /dev/random
  /opt/gpg_batch.sh
  mkdir -p /opt/aptly
  # If your system doesn't have a lot of entropy this may, take a long time
  # Google how-to create "artificial" entropy if this gets stuck
  gpg -v --batch --gen-key /opt/gpg_batch

else
  echo "No need to generate new gpg keys"
fi

# Import Ubuntu keyrings if they exist
if [[ -f /usr/share/keyrings/ubuntu-archive-keyring.gpg ]]; then
  gpg --list-keys
  gpg --no-default-keyring                                     \
      --keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg \
      --export |                                               \
  gpg --no-default-keyring                                     \
      --keyring trustedkeys.gpg                                \
      --import
fi

# Import Debian keyrings if they exist
if [[ -f /usr/share/keyrings/debian-archive-keyring.gpg ]]; then
  gpg --list-keys
  gpg --no-default-keyring                                     \
      --keyring /usr/share/keyrings/debian-archive-keyring.gpg \
      --export |                                               \
  gpg --no-default-keyring                                     \
      --keyring trustedkeys.gpg                                \
      --import
fi

# Aptly looks in /root/.gnupg for default keyrings
ln -sf /opt/aptly/aptly.sec /root/.gnupg/secring.gpg
ln -sf /opt/aptly/aptly.pub /root/.gnupg/pubring.gpg

# Generate Nginx Config
/opt/nginx.conf.sh

/opt/update_mirror_ubuntu.sh
