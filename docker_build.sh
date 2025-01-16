#!/bin/bash
set -e

# Get version from package.json
PACKAGE_VERSION=$(node -p "require('./package.json').version")
echo "Package version: $PACKAGE_VERSION"

# Docker repository settings
DOCKER_USERNAME="amberglass"
DOCKER_IMAGE_NAME="chartbrew"
DOCKER_REPO="$DOCKER_USERNAME/$DOCKER_IMAGE_NAME"

# Login to Docker Hub using 1password CLI
if command -v op &> /dev/null; then
    if ! op account get > /dev/null 2>&1; then
        eval $(op signin)
    fi
    
    # Get Docker credentials
    DOCKER_PASSWORD=$(op item get "goc4y6fiobfjrmqw4yojs5l4ue" --format json | jq -r '.fields[] | select(.id=="credential").value')
EOF

# Build and tag Docker image
docker build \
    --platform=linux/amd64 \
    --secret id=env,src=.env.local.prod \
    -t $DOCKER_REPO:latest \
    -t $DOCKER_REPO:$PACKAGE_VERSION \
    .

# Clean up the temporary env file
rm .env.local.prod

# Push Docker images
docker push $DOCKER_REPO:latest
docker push $DOCKER_REPO:$PACKAGE_VERSION

# Clean up
docker image rm $DOCKER_REPO:latest
docker image rm $DOCKER_REPO:$PACKAGE_VERSION

# Logout from Docker Hub
docker logout

echo "Successfully built and pushed version $PACKAGE_VERSION"