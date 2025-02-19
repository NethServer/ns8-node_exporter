#!/bin/bash

set -e
images=()
repobase="${REPOBASE:-ghcr.io/nethserver}"

reponame="node_exporter"
container=$(buildah from scratch)

# Reuse existing nodebuilder-node_exporter container, to speed up builds
if ! buildah containers --format "{{.ContainerName}}" | grep -q nodebuilder-node_exporter; then
    echo "Pulling NodeJS runtime..."
    buildah from --name nodebuilder-node_exporter -v "${PWD}:/usr/src:Z" docker.io/library/node:18.20.6-alpine
fi

echo "Build static UI files with node..."
buildah run \
    --workingdir "/usr/src/ui" \
    --env "NODE_OPTIONS=--openssl-legacy-provider" \
    nodebuilder-node_exporter \
    sh -c "yarn install --frozen-lockfile && yarn build"

buildah add "${container}" imageroot /imageroot
buildah add "${container}" ui/dist /ui
buildah config --entrypoint=/ "${container}"
buildah config --label="org.nethserver.rootfull=1" \
    --label="org.nethserver.max-per-node=1" \
    --label="org.nethserver.authorizations=traefik@any:routeadm" \
    --label="org.nethserver.flags=no_data_backup" \
	--label="org.nethserver.images=quay.io/prometheus/node-exporter:v1.9.0" \
	"${container}"
buildah commit "${container}" "${repobase}/${reponame}"
images+=("${repobase}/${reponame}")

#
#
#

if [[ -n "${CI}" ]]; then
    # Set output value for Github Actions
    printf "::set-output name=images::%s\n" "${images[*]}"
else
    printf "Publish the images with:\n\n"
    for image in "${images[@]}"; do printf "  buildah push %s docker://%s:latest\n" "${image}" "${image}" ; done
    printf "\n"
fi
