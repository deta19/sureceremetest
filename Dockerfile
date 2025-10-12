# ------------------------------
# Base PHP + Apache
# ------------------------------
FROM php:8.3-apache

ENV DEBIAN_FRONTEND=noninteractive

# ------------------------------
# Install system packages & PHP extensions
# ------------------------------
RUN apt-get update && apt-get install -y \
    git unzip zip curl nodejs npm \
    libpq-dev libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libicu-dev libldap2-dev libxml2-dev \
    libonig-dev libcurl4-openssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_pgsql pdo_mysql mysqli zip ldap intl soap \
    && a2enmod rewrite

# ------------------------------
# PHP configuration tweaks
# ------------------------------
RUN { \
  echo "upload_max_filesize=10M"; \
  echo "post_max_size=10M"; \
  echo "memory_limit=512M"; \
  echo "max_execution_time=300"; \
} > /usr/local/etc/php/conf.d/suitecrm.ini

# ------------------------------
# Install Composer globally
# ------------------------------
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# ------------------------------
# Set working directory
# ------------------------------
WORKDIR /var/www/html

# ------------------------------
# Copy setup script
# ------------------------------
COPY setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# ------------------------------
# Copy Apache vhost (must point to /public)
# ------------------------------
COPY apache/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN a2ensite 000-default.conf


# ------------------------------
# Expose ports
# ------------------------------
EXPOSE 80 443

# ------------------------------
# Run setup script at container start
# ------------------------------
CMD ["/usr/local/bin/setup.sh"]
