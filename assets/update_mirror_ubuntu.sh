#! /usr/bin/env bash
set -e
set -x

# Automate the initial creation and update of an Ubuntu package mirror in aptly

# The variables (as set below) will create a mirror of the Ubuntu repo
# with the main & universe components, you can add other components like restricted
# multiverse etc by adding to the array (separated by spaces).

# For more detail about each of the variables below refer to:
# https://help.ubuntu.com/community/Repositories/CommandLine

if [ "$MODE" = "packages" ]; then
    if [ ! -f "/opt/packages/$PACKAGE_FILE" ]; then
        echo "File with a package list is not found"
        exit 1
    fi
    FILTER_VAL=$(paste -sd \| "/opt/packages/$PACKAGE_FILE")
    FILTER_OPTS=("-filter=$FILTER_VAL" "-filter-with-deps")
else
    FILTER_OPTS=()
fi

REPO_DATE=$(date +%Y%m%d%H)

# Create repository mirrors if they don't exist
for component in ${COMPONENTS}; do
  for repo in ${REPOS}; do
    if ! aptly mirror list -raw | grep "^${repo}-${component}$"
    then
      echo "Creating mirror of ${repo}-${component} repository."
      aptly mirror create \
        -architectures=amd64 "${FILTER_OPTS[@]}" "${repo}-${component}" "${UPSTREAM_URL}" "${repo}" "${component}"
    fi
  done
done

# Update all repository mirrors
for component in ${COMPONENTS}; do
  for repo in ${REPOS}; do
    echo "Updating ${repo}-${component} repository mirror.."
    aptly mirror update "${repo}-${component}"
  done
done

SNAPSHOTARRAY=()
# Create snapshots of updated repositories
for component in ${COMPONENTS}; do
  for repo in ${REPOS}; do
    echo "Creating snapshot of ${repo}-${component} repository mirror.."
    SNAPSHOTARRAY+=("${repo}-${component}-$REPO_DATE")
    aptly snapshot create "${repo}-${component}-$REPO_DATE" from mirror "${repo}-${component}"
  done
done

echo "${SNAPSHOTARRAY[@]}"

# Merge snapshots into a single snapshot with updates applied
echo "Merging snapshots into one.."
aptly snapshot merge -latest                 \
  "${UBUNTU_RELEASE}-merged-$REPO_DATE"  \
  "${SNAPSHOTARRAY[@]}"

# Publish the latest merged snapshot
if aptly publish list -raw | awk '{print $2}' | grep "^${UBUNTU_RELEASE}$"
then
  aptly publish switch            \
    -batch=true \
    -passphrase="${GPG_PASSWORD}" \
    "${UBUNTU_RELEASE}" "${UBUNTU_RELEASE}-merged-$REPO_DATE"
else
  aptly publish snapshot \
    -batch=true \
    -passphrase="${GPG_PASSWORD}" \
    -distribution="${UBUNTU_RELEASE}" "${UBUNTU_RELEASE}-merged-$REPO_DATE"
fi

# Export the GPG Public key
if [[ ! -f /opt/aptly/public/aptly_repo_signing.key ]]; then
  gpg --export --armor > /opt/aptly/public/aptly_repo_signing.key
fi

# Generate Aptly Graph
aptly graph -output /opt/aptly/public/aptly_graph.png
