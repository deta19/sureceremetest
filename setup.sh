#!/bin/bash
set -e

APP_DIR="/var/www/html"

echo "🚀 SuiteCRM setup starting..."

# Ensure correct working directory
cd "$APP_DIR"



# Install PHP dependencies
echo "📦 Installing PHP dependencies..."
if [ -f composer.json ]; then
  composer install --no-interaction --no-progress --prefer-dist || true
else
  echo "⚠️  No composer.json found, skipping Composer install."
fi

# Optional: if SuiteCRM frontend exists (for v8+)
if [ -f package.json ]; then
  echo "📦 Updating npm to latest version..."
  npm install -g npm@latest
  
  echo "📦 Installing Node.js dependencies..."
  npm install --legacy-peer-deps --no-audit --no-fund || true

  echo "🏗️  Building frontend..."
  npm run build --if-present || true
fi

# Optional: fix permissions (safe even if run multiple times)
echo "🔧 Fixing permissions..."
# chown -R www-data:www-data "$APP_DIR"
# chmod -R 775 "$APP_DIR"

for dir in cache custom modules themes data upload var public/var; do
    mkdir -p "$APP_DIR/$dir"
    chown -R --no-dereference www-data:www-data "$APP_DIR/$dir"
    chmod -R --quiet 775 "$APP_DIR/$dir"
done

echo "✅ Starting Apache..."
exec apache2-foreground
