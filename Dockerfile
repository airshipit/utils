# Copyright 2018 Artem B. Smirnov
# Copyright 2018 Jon Azpiazu
# Copyright 2016 Bryan J. Hong
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:xenial

LABEL maintainer="airship-team@att.com"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-key adv --keyserver pool.sks-keyservers.net --recv-keys ED75B5A4483DA07C \
  && echo "deb http://repo.aptly.info/ squeeze main" >> /etc/apt/sources.list

# Update APT repository & install packages
RUN apt-get -q update \
  && apt-get -y install \
    aptly=1.3.0 \
    bzip2 \
    gnupg=1.4.20-1ubuntu3.3 \
    gpgv=1.4.20-1ubuntu3.3 \
    graphviz=2.38.0-12ubuntu2.1 \
    supervisor=3.2.0-2ubuntu0.2 \
    nginx=1.10.3-0ubuntu0.16.04.2 \
    wget \
    xz-utils=5.1.1alpha+20120614-2ubuntu2 \
    apt-utils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Aptly Configuration
COPY assets/aptly.conf /etc/aptly.conf

# Install scripts
COPY assets/*.sh /opt/

# Install Nginx Config
RUN rm /etc/nginx/sites-enabled/*
COPY assets/supervisord.nginx.conf /etc/supervisor/conf.d/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

ARG FULL_NAME="First Last"
ARG EMAIL_ADDRESS="youremail@example.com"
ARG GPG_PASSWORD="PickAPassword"
ARG HOSTNAME=localhost
ARG MODE=packages
ARG UBUNTU_RELEASE=xenial
ARG UPSTREAM_URL="http://archive.ubuntu.com/ubuntu/"
ARG COMPONENTS="main universe"
ARG REPOS="${UBUNTU_RELEASE} ${UBUNTU_RELEASE}-updates ${UBUNTU_RELEASE}-security"

ENV FULL_NAME ${FULL_NAME}
ENV EMAIL_ADDRESS ${EMAIL_ADDRESS}
ENV GPG_PASSWORD ${GPG_PASSWORD}
ENV HOSTNAME ${HOSTNAME}
ENV MODE ${MODE}
ENV UBUNTU_RELEASE=${UBUNTU_RELEASE}
ENV UPSTREAM_URL=${UPSTREAM_URL}
ENV COMPONENTS=${COMPONENTS}
ENV REPOS=${REPOS}

COPY assets/packages /opt/packages
COPY assets/gpg/* /opt/aptly/

RUN /opt/startup.sh

# Execute Startup script when container starts

VOLUME [ "/opt/nginx" ]

CMD [ "/opt/run.sh" ]
