#!/bin/bash
set -e

APP_DIR="/var/www/html/app"
mkdir -p "$APP_DIR"

echo "🚀 Installing SuiteCRM..."
if [ ! -d "$APP_DIR/public" ]; then
  curl -L -o suitecrm.zip https://sourceforge.net/projects/suitecrm/files/SuiteCRM-8.1.0.zip/download
  unzip suitecrm.zip -d "$APP_DIR"
  rm suitecrm.zip
  if [ -d "$APP_DIR/SuiteCRM-8.1.0" ]; then
    mv "$APP_DIR/SuiteCRM-8.1.0/"* "$APP_DIR/"
    rm -rf "$APP_DIR/SuiteCRM-8.1.0"
  fi
fi

echo "📦 Installing PHP dependencies..."
composer install --no-interaction --no-progress --prefer-dist || true

echo "🔧 Setting permissions..."
chown -R www-data:www-data "$APP_DIR"
chmod -R 775 "$APP_DIR"

echo "✅ Starting Apache..."
exec apache2-foreground
