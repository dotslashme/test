#!/usr/bin/env bash

declare artemis_version
declare source_dir
declare latest_version
script_path=$(dirname "$0")
script_path=$(cd "${script_path}" && pwd)
source_dir="${script_path}/activemq_artemis"
readonly source_dir

# Clone Artemis source code repository
git clone https://github.com/apache/activemq-artemis.git "${source_dir}"

# Build either a provided version or latest tag from the repository
cd "${source_dir}" || exit 1
latest_version="$(git describe --tags --abbrev=0)"
artemis_version="${1:-$latest_version}"
readonly artemis_version

# Prepare the sources for this version
cd "${source_dir}/artemis-docker" || exit 1
./prepare-docker.sh --from-release --artemis-version "${artemis_version}"
echo "$artemis_version"
