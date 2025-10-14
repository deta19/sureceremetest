FROM php:8.3-apache

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /var/www/html

# ----------------------------------------------------
# Install all dependencies, PHP extensions, Composer, and Node.js
# ----------------------------------------------------
RUN apt-get update && apt-get install -y \
      unzip git curl zip nodejs npm \
      libpng-dev libjpeg-dev libfreetype6-dev \
      libicu-dev libzip-dev libxml2-dev \
      libldap2-dev libonig-dev libcurl4-openssl-dev \
  && docker-php-ext-configure gd --with-jpeg --with-freetype \
  && docker-php-ext-install gd intl zip pdo pdo_mysql mysqli opcache ldap soap mbstring \
  && a2enmod rewrite \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && npm install -g npm@latest \
  && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------
# Copy application and setup script
# ----------------------------------------------------
COPY . .
COPY setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 80
CMD ["/usr/local/bin/setup.sh"]
