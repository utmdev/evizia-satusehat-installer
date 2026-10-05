#!/usr/bin/env bash
set -e

# ==============================================================================
# 🏥 SATUSEHAT Integration Engine - Automated Installation Script
# Dibuat untuk Tim IT Rumah Sakit / Faskes (Zero-Effort Auto Install)
# ==============================================================================

echo ""
echo "=================================================================="
echo "  🏥 SATUSEHAT Integration Engine - Setup & Installation Wizard  "
echo "=================================================================="
echo ""

# 1. Cek Apakah Docker & Docker Compose Terpasang
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker belum terinstal di server ini."
    echo "   Silakan install Docker terlebih dahulu: https://docs.docker.com/engine/install/"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo "❌ Error: Docker Compose plugin belum terinstal."
    exit 1
fi

echo "✔ Docker & Docker Compose terdeteksi aktif."
echo ""

# 2. Setup File .env
if [ -f .env ]; then
    echo "ℹ File .env sudah ada. Menggunakan konfigurasi yang ada."
else
    echo "⚙ Mengonfigurasi environment aplikasi..."
    
    # Generate Kunci Keamanan Acak Otomatis
    GEN_CONFIG_KEY=$(openssl rand -hex 32 2>/dev/null || cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 64 | head -n 1)
    GEN_JWT_SECRET=$(openssl rand -base64 32 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    GEN_BRIDGE_KEY=$(openssl rand -hex 24 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 48 | head -n 1)
    GEN_DB_PASSWORD=$(openssl rand -hex 16 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

    echo "------------------------------------------------------------------"
    read -p "Gunakan database PostgreSQL bawaan Docker container? (Y/n) [Y]: " USE_BUNDLED_DB
    USE_BUNDLED_DB=${USE_BUNDLED_DB:-Y}

    if [[ "$USE_BUNDLED_DB" =~ ^[Yy]$ ]]; then
        COMPOSE_PROFILES="with-db"
        DB_HOST="postgresql"
        DB_PORT="5432"
        DB_NAME="satusehat_engine"
        DB_USER="satusehat_user"
        DB_PASS="${GEN_DB_PASSWORD}"
        echo "✔ Menggunakan database PostgreSQL bawaan container (Auto-provisioning aktif)."
    else
        COMPOSE_PROFILES=""
        echo "Silakan masukkan kredensial PostgreSQL eksternal Anda:"
        read -p "Database Host [127.0.0.1]: " DB_HOST
        DB_HOST=${DB_HOST:-127.0.0.1}

        read -p "Database Port [5432]: " DB_PORT
        DB_PORT=${DB_PORT:-5432}

        read -p "Database Name [satusehat_engine]: " DB_NAME
        DB_NAME=${DB_NAME:-satusehat_engine}

        read -p "Database User [postgres]: " DB_USER
        DB_USER=${DB_USER:-postgres}

        read -sp "Database Password: " DB_PASS
        echo ""
    fi

    echo "------------------------------------------------------------------"
    read -p "Port Web Portal [80]: " WEB_PORT
    WEB_PORT=${WEB_PORT:-80}

    # Tulis file .env
    cat <<EOF > .env
NODE_ENV=production

# Registry Image
IMAGE_PREFIX=ghcr.io/utmdev/evizia-satusehat-engine

# Profile Docker (with-db untuk menyalakan database container)
COMPOSE_PROFILES=${COMPOSE_PROFILES}

# PostgreSQL Database
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASS}
DATABASE_URL=postgresql://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}

# Keamanan & Enkripsi (Auto-Generated)
JWT_SECRET=${GEN_JWT_SECRET}
JWT_EXPIRES_IN=8h
CONFIG_ENCRYPTION_KEY=${GEN_CONFIG_KEY}

# Port & Network
API_PORT=3000
WEB_PORT=${WEB_PORT}
PG_BOSS_SCHEMA=pgboss
CORS_ORIGINS=*

# API Key untuk Bridging SIMRS (Auto-Generated)
SIMRS_BRIDGE_API_KEY=${GEN_BRIDGE_KEY}

# Proteksi Rate Limiting
RATE_LIMIT_TTL_MS=60000
RATE_LIMIT_MAX=120
RATE_LIMIT_AUTH_MAX=10
RATE_LIMIT_EVENTS_MAX=300
EOF

    echo "✔ File .env berhasil dibuat otomatis."
fi

echo ""
echo "------------------------------------------------------------------"
echo "🚀 Mengunduh & Menjalankan seluruh container (DB, API, Worker, UI, Watchtower)..."
echo "------------------------------------------------------------------"

docker compose up -d

echo ""
echo "=================================================================="
echo "🎉 INSTALASI SATUSEHAT ENGINE BERHASIL (ALL-IN-ONE)!"
echo "=================================================================="
echo ""
echo "📌 AKSES WEB PORTAL:"
echo "   URL      : http://<IP_SERVER_ANDA>:${WEB_PORT:-80}"
echo "   Username : admin"
echo "   Password : admin (Wajib ganti pada saat login pertama)"
echo ""
echo "📡 KONEKSI BRIDGING SIMRS:"
echo "   Endpoint : POST http://<IP_SERVER_ANDA>:3000/api/events"
echo "   Header   : X-SIMRS-API-Key: $(grep SIMRS_BRIDGE_API_KEY .env | cut -d '=' -f2)"
echo "=================================================================="
echo ""
