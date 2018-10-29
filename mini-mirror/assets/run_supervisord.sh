#!/usr/bin/env bash

set -o pipefail
set -o errexit
# set -o xtrace

/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
