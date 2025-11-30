# Use the official lightweight Nginx image as the base
# This provides a stable, small web server environment.
FROM nginx:alpine

# The Nginx default configuration expects HTML files to be in this directory.
# Copy your index.html from the build context (your Git repo) into the 
# Nginx web root directory inside the container.
COPY index.html /usr/share/nginx/html/

# Expose port 80 to the host environment (standard HTTP port).
# This is documentation for the container; the Jenkins script handles the actual port mapping.
EXPOSE 80

# The base image already has the CMD defined to start Nginx, 
# so no further instruction is needed.
