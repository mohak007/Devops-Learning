#!/bin/bash
# =======================================================
# Docker Compose Deployment Script
# This script handles the pre-build file preparation and 
# executes the Docker Compose build and run steps explicitly 
# to avoid conflicts with Docker CLI versions on the agent.
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

echo "2. Deploying service using Docker Compose (Two-Step Process)..."

# STEP 2a: Explicitly build the image first.
# This step creates the 'dashboard:main' image using the Dockerfile and index.html copy.
echo "   -> Building Docker image..."
sudo docker compose build

if [ $? -ne 0 ]; then
    echo "ERROR: Docker Compose BUILD failed."
    # Clean up the temporary copy before exiting on failure
    rm "${EXPECTED_FILE_DESTINATION}" || true
    exit 1
fi

# STEP 2b: Run/recreate the container using the newly built image.
# 'up -d' starts the service, recreating the container using the latest built image.
echo "   -> Starting/Recreating container..."
sudo docker compose up -d

# Check if the compose command was successful
if [ $? -ne 0 ]; then
    echo "ERROR: Docker Compose UP failed."
    # Clean up the temporary copy before exiting on failure
    rm "${EXPECTED_FILE_DESTINATION}" || true
    exit 1
fi

# Clean up the temporary copy after the build is done
rm "${EXPECTED_FILE_DESTINATION}" || true
echo "Deployment finished. Docker Compose service is running."
