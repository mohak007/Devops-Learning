#!/bin/bash
# --- Jenkins Pipeline Docker Deployment ---

# Use lowercase name to satisfy Docker naming rules
IMAGE_NAME="dashboard:main"
CONTAINER_NAME="vm-dashboard-container"
HOST_PORT="80"
CONTAINER_PORT="80"

echo "1. Cleaning up any previous running container ($CONTAINER_NAME)..."
# Stop and remove the old container instance (ignoring errors if it doesn't exist)
sudo docker stop ${CONTAINER_NAME} || true
sudo docker rm ${CONTAINER_NAME} || true

echo "1.5. Stopping host Nginx service to free port 80..."
# **CRITICAL STEP: Stop the Nginx service running directly on the EC2 host**
# This resolves the "address already in use" error by freeing port 80.
sudo systemctl stop nginx || true

echo "2. Building Docker image: ${IMAGE_NAME} from current directory..."
# Build the image. 
sudo docker build -t ${IMAGE_NAME} .

# Check if the build command was successful (exit code 0)
if [ $? -ne 0 ]; then
    echo "ERROR: Docker image build failed. Check Dockerfile or context."
    exit 1
fi

echo "3. Running new container: ${CONTAINER_NAME} on port ${HOST_PORT}:${CONTAINER_PORT}"
# Run the container in detached mode (-d) and map host port 80 to container port 80.
sudo docker run -d \
    --restart always \
    --name ${CONTAINER_NAME} \
    -p ${HOST_PORT}:${CONTAINER_PORT} \
    ${IMAGE_NAME}

echo "Deployment finished. Check your EC2 Public IP address."
