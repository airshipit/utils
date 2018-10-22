# docker-aptly

## Features

- Packages are downloaded during the docker image build
- GPG keys for signature may be generated during the docker image build or existing ones are used
- Nginx blacklist support at runtime

## Quickstart

The main difference with the upstream repo is packages saved inside a docker image.
During the image building /opt/update_mirror_ubuntu.sh is called to create mirrors, update them,
merge all in one snapshot and publish it. By default, a new GPG key is generated for making a signature for repo.

There are two modes: filtered build that fetches only packages specified in assets/packages and
unfiltered build that fetches all packages. The filtered build is used by default.

To fetch all packages the following command can be used:

```bash
git clone https://github.com/urpylka/docker-aptly.git
docker build docker-aptly --build-arg MODE=all
```

By default GPG key for making package signature are generated during the build.
You may configure GPG key params via build arguments: FULL_NAME, EMAIL_ADDRESS, and GPG_PASSWORD, like:

```bash
docker build docker-aptly \
  --build-arg FULL_NAME="First Last" \
  --build-arg EMAIL_ADDRESS="youremail@example.com" \
  --build-arg GPG_PASSWORD="PickAPassword"
```

If you have a GPG key already you can put private and public key in assets/gpg dir.
Keys must have special names: aptly.sec and aptly.pub
For example:

```bash
cp <my private key> docker-aptly/assets/gpg/aptly.sec
cp <my public key> docker-aptly/assets/gpg/aptly.pub

docker build docker-aptly \
  --build-arg GPG_PASSWORD="GPG passphrase for my private key"
```

To use the Nginx blacklist feature a volume with Nginx config has to be mounted at runtime.
By default, the following keywords are blocked: telnet, ftp.
If no volume is mounted then no blacklist will be used.

```bash
docker run \
  --name aptly \
  --detach \
  --publish 8080:80 \
  --volume $(pwd)/assets/nginx:/opt/nginx \
  aptly:test
```
___

For additional docs see https://github.com/amadev/docker-aptly

* Copyright 2018 Artem B. Smirnov
* Copyright 2016 Bryan J. Hong
* Licensed under the Apache License, Version 2.0
