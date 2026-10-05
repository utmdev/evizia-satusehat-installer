# 🏥 Panduan Instalasi SATUSEHAT Integration Engine (Untuk Tim IT Faskes)

Panduan ringkas ini ditujukan untuk Tim IT / Sysadmin Rumah Sakit untuk melakukan instalasi **SATUSEHAT Integration Engine**.

---

## 📋 Prasyarat Server
1. **Sistem Operasi**: Linux (Ubuntu 20.04/22.04/24.04 LTS, Debian, CentOS, Rocky Linux).
2. **Tools**: Docker & Docker Compose sudah terpasang.
3. **Koneksi Internet**: Diperlukan saat pertama kali instalasi untuk mengunduh image aplikasi.

---

## ⚡ Langkah Instalasi (Mudah & Cepat)

### Langkah 1: Upload & Ekstrak File ZIP
Upload file `satusehat-installer.zip` ke server Linux Anda (misal ke folder `/opt/satusehat-engine`), lalu ekstrak:

```bash
# 1. Buat folder instalasi
sudo mkdir -p /opt/satusehat-engine
sudo chown -R $USER:$USER /opt/satusehat-engine
cd /opt/satusehat-engine

# 2. Ekstrak file zip installer
unzip satusehat-installer.zip
```

---

### Langkah 2: Login Docker (Otentikasi Registry)
Jalankan perintah ini sekali di terminal server untuk mengizinkan server mengunduh image aplikasi dari vendor:

```bash
echo "TOKEN_YANG_DIBERIKAN_VENDOR" | docker login ghcr.io -u USERNAME_VENDOR --password-stdin
```

---

### Langkah 3: Jalankan Script Setup Otomatis
Jalankan script wizard instalasi:

```bash
chmod +x setup.sh
./setup.sh
```

*Wizard akan menanyakan apakah ingin menggunakan database PostgreSQL bawaan container (Default: Ya). Kunci enkripsi AES-256, password database, dan API Key SIMRS akan di-generate otomatis oleh script.*

---

### Langkah 4: Selesai & Akses Portal
Setelah instalasi selesai, terminal akan menampilkan informasi akses:
1. **URL Portal Web**: `http://<IP_SERVER_ANDA>` (Login awal: `admin` / `admin`).
2. **API Key SIMRS**: Diberikan kepada tim pengembang SIMRS pada header `X-SIMRS-API-Key`.

---

## 🛠️ Perintah Operasional Harian
* **Cek Status Service**: `docker compose ps`
* **Melihat Log Aplikasi**: `docker compose logs -f`
* **Restart Aplikasi**: `docker compose restart`
* **Stop Aplikasi**: `docker compose down`

> ℹ **Fitur Auto-Update**: Aplikasi ini dilengkapi dengan *Watchtower*. Setiap kali vendor merilis perbaikan/fitur baru, aplikasi akan otomatis terupdate di server Anda secara berkala tanpa perlu instalasi ulang.
