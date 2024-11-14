#!/bin/bash

duckdb_version=v1.1.3
image_name=luvx/duckdb:"${duckdb_version}"
platforms="linux/amd64,linux/arm64"

echo "Getting latest tag version from duckdb"

if [ -z "$(DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect "$image_name" 2> /dev/null)" ]; then
  echo "Building for duckdb version: ${duckdb_version}"

  docker run --privileged --rm tonistiigi/binfmt --install all
  docker buildx create --use --name builder
  docker buildx inspect --bootstrap builder

  docker buildx build \
    -t "$image_name" \
    --platform "$platforms" \
    --build-arg "DUCKDB_VERSION=${duckdb_version}" . --push

  echo "Done!"
else
  echo "Latest duckdb image version already exists, version: ${duckdb_version}"
fi