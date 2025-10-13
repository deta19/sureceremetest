#!/bin/bash
set -e

APP_DIR="/var/www/html/app"
mkdir -p "$APP_DIR"

# echo "🚀 Installing SuiteCRM..."
# if [ ! -d "$APP_DIR/public" ]; then
#   curl -L -o suitecrm.zip https://sourceforge.net/projects/suitecrm/files/SuiteCRM-8.1.0.zip/download
#   unzip suitecrm.zip -d "$APP_DIR"
#   rm suitecrm.zip
#   if [ -d "$APP_DIR/SuiteCRM-8.1.0" ]; then
#     mv "$APP_DIR/SuiteCRM-8.1.0/"* "$APP_DIR/"
#     rm -rf "$APP_DIR/SuiteCRM-8.1.0"
#   fi
# fi
echo "📦 Installing PHP dependencies in $APP_DIR ..."
cd "$APP_DIR" || { echo "❌ Failed to enter $APP_DIR"; exit 1; }

if [ -f "composer.json" ]; then
    composer install --no-interaction --no-progress --prefer-dist
else
    echo "⚠️ No composer.json found in $APP_DIR — skipping composer install."
    echo "Files in directory:"
    ls -la
fi

# echo "🔧 Setting permissions..."
# chown -R www-data:www-data "$APP_DIR"
# chmod -R 775 "$APP_DIR"

echo "✅ Starting Apache..."
exec apache2-foreground
