#!/bin/bash
set -e

export PATH=/usr/local/bin:$PATH

echo "🚀 Running SuiteCRM setup tasks..."

APP_DIR="/var/www/html/app"
mkdir -p "$APP_DIR"

# ------------------------------
# Download SuiteCRM zip if not present
# ------------------------------
if [ ! -f "$APP_DIR/README.md" ]; then
    echo "📦 Downloading SuiteCRM archive..."
    curl -L -o suitecrm.zip https://sourceforge.net/projects/suitecrm/files/SuiteCRM-8.1.0.zip/download

    echo "🗜️ Extracting SuiteCRM..."
    unzip suitecrm.zip -d "$APP_DIR"
    rm suitecrm.zip

    # Some archives create a nested folder, move files up if necessary
    if [ -d "$APP_DIR/SuiteCRM-8.1.0" ]; then
        mv "$APP_DIR/SuiteCRM-8.1.0/"* "$APP_DIR/"
        rm -rf "$APP_DIR/SuiteCRM-8.1.0"
    fi
else
    echo "📦 SuiteCRM already exists, skipping download."
fi

cd "$APP_DIR"

# ------------------------------
# Install Node dependencies and build frontend
# ------------------------------
if [ -f package.json ]; then
    echo "🧩 Installing Node.js dependencies..."
    if ! npm install --legacy-peer-deps; then
        echo "⚠️ npm install failed, retrying with --force..."
        npm install --force
    fi

    echo "🏗️ Building frontend assets..."
    npm run build || npm run dev
fi

# ------------------------------
# Fix permissions
# ------------------------------
echo "🔧 Fixing permissions..."
chown -R www-data:www-data "$APP_DIR"
chmod -R 775 cache custom modules themes data upload var public/var || true

# ------------------------------
# Start Apache
# ------------------------------
echo "✅ Setup complete! Starting Apache..."
exec apache2-foreground
