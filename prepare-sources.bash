#!/usr/bin/env bash
set -x
declare artemis_version
declare source_dir
declare latest_version
script_path=$(dirname "$0")
script_path=$(cd "${script_path}" && pwd)
source_dir="$1"
readonly source_dir

# Clone Artemis source code repository
git clone https://github.com/apache/activemq-artemis.git "${source_dir}"

# Build either a provided version or latest tag from the repository
cd "${source_dir}" || exit 1
latest_version="$(git describe --tags --abbrev=0)"
artemis_version="${2:-$latest_version}"
readonly artemis_version

if [[ "${artemis_version}" != "latest" && "${artemis_version}" != "${latest_version}" ]]; then
  # We have supplied a manual version, check it and set it if it exists as a tag
  git tag | grep "${artemis_version}" &> /dev/null
  test $? -eq 0 || exit 1
  printf "%s|%s" "${artemis_version}" "${artemis_version}" > "${PWD}/versions.txt"
elif [[ "${artemis_version}" != "latest" && "${artemis_version}" == "${latest_version}" ]]; then
  printf "%s|%s" "${artemis_version}" "release" > "${PWD}/versions.txt"
else
  printf "%s|%s" "${artemis_version}" "latest" > "${PWD}/versions.txt"
fi
