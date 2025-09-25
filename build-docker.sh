#!/bin/bash

# DocuSeal Pro Features Unlocked - Docker Build Script
set -e

# Configuration
IMAGE_NAME="docuseal-pro-unlocked"
TAG="latest"
REGISTRY_URL="" # Add your registry URL here (e.g., docker.io/username, ghcr.io/username)

echo "🏗️ Building DocuSeal with Pro Features Unlocked..."
echo "Image: ${IMAGE_NAME}:${TAG}"

# Build the Docker image
docker build \
  --platform linux/amd64,linux/arm64 \
  -t ${IMAGE_NAME}:${TAG} \
  -f Dockerfile \
  .

echo "✅ Build completed successfully!"

# Optional: Tag for registry
if [ ! -z "$REGISTRY_URL" ]; then
  echo "🏷️ Tagging for registry..."
  docker tag ${IMAGE_NAME}:${TAG} ${REGISTRY_URL}/${IMAGE_NAME}:${TAG}
  
  echo "📤 Push to registry? (y/n)"
  read -r push_choice
  if [ "$push_choice" = "y" ]; then
    docker push ${REGISTRY_URL}/${IMAGE_NAME}:${TAG}
    echo "✅ Pushed to registry: ${REGISTRY_URL}/${IMAGE_NAME}:${TAG}"
  fi
fi

echo "🚀 Ready to deploy!"
echo ""
echo "To run locally:"
echo "docker run -p 3000:3000 -v \$(pwd)/data:/data ${IMAGE_NAME}:${TAG}"
echo ""
echo "To deploy:"
echo "Use the docker-compose.yml file or your preferred deployment method"
