#!/bin/bash
# =======================================================
# Docker Compose Deployment Script
# 1. Prepares the build context by copying the HTML file.
# 2. Executes 'docker compose up' to build, recreate, and start the service.
# =======================================================

# Configuration Variables
NEW_FILE_SOURCE="jenkins_build_vm_status_panel.html"
EXPECTED_FILE_DESTINATION="index.html" 

echo "0. Setting up Docker build context: Copying ${NEW_FILE_SOURCE} to ${EXPECTED_FILE_DESTINATION}."
# Create a temporary file named 'index.html' that the Dockerfile expects
if [ -f "${NEW_FILE_SOURCE}" ]; then
    cp "${NEW_FILE_SOURCE}" "${EXPECTED_FILE_DESTINATION}"
    echo "   Successfully copied ${NEW_FILE_SOURCE} to ${EXPECTED_FILE_DESTINATION}."
else
    echo "ERROR: Source file ${NEW_FILE_SOURCE} not found in the workspace."
    exit 1
fi

echo "1. Stopping host Nginx service to free port 80 (If applicable)..."
sudo systemctl stop nginx || true

echo "2. Deploying service using Docker Compose..."

# 'docker compose' handles building, replacing, and starting the container in detached mode (-d).
# '--force-recreate' ensures the service is updated.
# '--build' forces a rebuild using the prepared context.
sudo docker compose up --build -d

# Check if the compose command was successful
if [ $? -ne 0 ]; then
    echo "ERROR: Docker Compose deployment failed."
    # Clean up the temporary copy before exiting on failure
    rm "${EXPECTED_FILE_DESTINATION}" || true
    exit 1
fi

# Clean up the temporary copy after the build is done
rm "${EXPECTED_FILE_DESTINATION}" || true
echo "Deployment finished. Docker Compose service is running."
