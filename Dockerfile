# Use an official Apache image
FROM httpd

# Copy index.html into Apache web root
COPY index.html /usr/local/apache2/htdocs/

# Expose port 80
EXPOSE 80
