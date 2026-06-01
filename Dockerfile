FROM php:8.2-apache

# Copy all files from the current directory to the web server root
COPY . /var/www/html/

# Ensure the flutter app directory is not served by Apache (optional, but good practice)
# We can just ignore it in .dockerignore or let it be

# Enable Apache mod_rewrite just in case
RUN a2enmod rewrite

# Update permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
