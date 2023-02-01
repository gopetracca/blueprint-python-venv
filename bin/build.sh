#!/usr/bin/env bash

# Build docker image.

set -x

# Variables
APP_NAME=${1:-blueprint}
IMAGE_TAG=${IMAGE_TAG:-latest}
BUILD_TARGET=${BUILD_TARGET:-dev}

# Config Docker
export DOCKER_BUILDKIT=1

# Build the image
docker build -f Dockerfile \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --target $BUILD_TARGET \
    --tag $APP_NAME:$IMAGE_TAG .
