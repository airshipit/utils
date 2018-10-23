#! /usr/bin/env bash

# Copyright 2018 Artem B. Smirnov
# Copyright 2016 Bryan J. Hong
# Licensed under the Apache License, Version 2.0

cat << EOF > /etc/nginx/conf.d/default.conf
server_names_hash_bucket_size 64;
server {
  root /opt/aptly/public;
  server_name ${HOSTNAME};

  location / {
    autoindex on;
  }

  include /opt/nginx/*.conf;
}
EOF
