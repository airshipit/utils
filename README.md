# Airship-utils

Airship-utils is a collection of tools that can accompany other airship-* projects.
Currently, airship-utils contains the following components:

- miniMirror

## miniMirror

miniMirror is a combination of package mirroring tool (Aptly) and a web server (Nginx)
packed into a container and a helm chart for k8s deployment. See [1] for additional info.

### Features

- Packages are downloaded during the docker image build.
  A list of packages can be specified with particular versions or
  without them to get the current snapshot. Currently miniMirror
  focuses on Ubuntu repositories only.
- GPG key for signature can be generated during the docker image build
  or existing one can be used. To make a signature for packages Aptly
  requires a private key, it is not possible to use a signature from
  original mirror.
- Packages blacklist support at runtime. An additional Nginx
  configuration can be provided to block specific package
  installation. By default packages contains the following regexp in name are blocked:
  - telnet
  - ftp
  - \brsh\b
  - \bnis\b

### How to build miniMirror image?

#### General desription

As an upstream repository is packages saved inside a docker image it
may take some time to build the image. The process of building the image
includes the following steps:

- Prepare GPG environment (see assets/startup.sh for details).
  - Put into right places or generate GPG key depending on the build
    configuration.
  - Update GPG keyring.
- Create packages infrastructure (see assets/
  - Create Aptly mirrors
  - Fetch packages from upstream repositories according to the mirrors
    configuration.
  - Merge repositories. For example, by default xenial, xenial-updates,
    and xenial-security are used. Packages from each repository are
    merged into on with latest wins strategy.
  - Publish repository to directory Nginx will serve static files
  - from.

#### Configuration

The following build args are available:

Repository configuration:

- UPSTREAM_URL - an URL packages are downloaded from
- UBUNTU_RELEASE - a release name for Ubuntu distributive
- COMPONENTS - a list of repository components separated by space.
  For example, values can be main, universe, restricted, multiverse [2].
- REPOS - a list of repository types separated by space.
  For example xenial, xenial-updates, xenial-security, xenial-backports.

Packages configuration:
- MODE - a string determining if all packages should be downloaded or
  specific only. Possible values: packages or all.
- PACKAGE_FILE - a file name where a list of packages is saved. If
  MODE=packages the file must be available in assets/packages
  directory.

GPG key configuration:
- FULL_NAME - a full name for a GPG key
- EMAIL_ADDRESS - an email for a GPG key
- GPG_PASSWORD - a passphrase for a GPG key

Nginx configuration:
- HOSTNAME - server_name configuration for Nginx.

Example:

```bash
git clone https://git.openstack.org/openstack/airship-utils
docker build airship-utils \
  --UBUNTU_RELEASE=bionic \
  --build-arg FULL_NAME="John Smith" \
  --build-arg EMAIL_ADDRESS="john.smith@example.com" \
  --build-arg GPG_PASSWORD="PickAPassword" \
  --build-arg HOSTNAME=_
```

## References

* [1] https://review.openstack.org/#/c/611376/
* [2] https://help.ubuntu.com/community/Repositories

## Copyright

* Copyright 2018 AT&T Intellectual Property
* Copyright 2018 Artem B. Smirnov
* Copyright 2016 Bryan J. Hong
* Licensed under the Apache License, Version 2.0
