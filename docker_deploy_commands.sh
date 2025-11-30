#!/bin/bash
# --- Docker Deployment Script for VM Dashboard ---

# Configuration Variables
IMAGE_NAME="dashboard:main"
CONTAINER_NAME="vm-dashboard-container"
HOST_PORT="80"
CONTAINER_PORT="80"
NEW_FILE_SOURCE="jenkins_build_vm_status_panel.html"
EXPECTED_FILE_DESTINATION="index.html" # Name expected by your Dockerfile's COPY instruction

echo "0. Setting up Docker build context..."
# Create a temporary file named 'index.html' that the Dockerfile expects,
# using the content of your new file.
if [ -f "${NEW_FILE_SOURCE}" ]; then
    cp "${NEW_FILE_SOURCE}" "${EXPECTED_FILE_DESTINATION}"
    echo "   Successfully copied ${NEW_FILE_SOURCE} to ${EXPECTED_FILE_DESTINATION} for Docker build."
else
    echo "ERROR: Source file ${NEW_FILE_SOURCE} not found in the workspace."
    exit 1
fi

echo "1. Cleaning up any previous running container ($CONTAINER_NAME)..."
sudo docker stop ${CONTAINER_NAME} || true
sudo docker rm ${CONTAINER_NAME} || true

echo "1.5. Stopping host Nginx service to free port 80..."
sudo systemctl stop nginx || true

echo "2. Building Docker image: ${IMAGE_NAME} from current directory..."
# The build will now copy the 'index.html' (which contains the new content)
sudo docker build -t ${IMAGE_NAME} .

# Check if the build command was successful (exit code 0)
if [ $? -ne 0 ]; then
    echo "ERROR: Docker image build failed. Check Dockerfile or context."
    exit 1
fi

echo "3. Running new container: ${CONTAINER_NAME} on port ${HOST_PORT}:${CONTAINER_PORT}"
sudo docker run -d \
    --restart always \
    --name ${CONTAINER_NAME} \
    -p ${HOST_PORT}:${CONTAINER_PORT} \
    ${IMAGE_NAME}

# Clean up the temporary copy after the build is done (optional, but good practice)
rm "${EXPECTED_FILE_DESTINATION}" || true
echo "Deployment finished. Check your EC2 Public IP address to view the dashboard."
