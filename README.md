# 🏥 Panduan Instalasi SATUSEHAT Integration Engine (Untuk Tim IT Faskes)

Panduan ringkas ini ditujukan untuk Tim IT / Sysadmin Rumah Sakit untuk melakukan instalasi **SATUSEHAT Integration Engine**.

---

## 📋 Spesifikasi Server
1. **Sistem Operasi**: Linux (Ubuntu 20.04/22.04/24.04 LTS, Debian, CentOS, Rocky Linux).
2. **Tools**: Docker & Docker Compose sudah terpasang.
3. **Koneksi Internet**: Diperlukan saat pertama kali instalasi untuk mengunduh image aplikasi.

---

## ⚡ Langkah Instalasi

### Langkah 1: Clone Repositori Installer
Unduh berkas installer ke folder `/opt/satusehat-engine`:

```bash
git clone https://github.com/utmdev/evizia-satusehat-installer.git /opt/satusehat-engine
cd /opt/satusehat-engine
```

---

### Langkah 2: Login Docker (Otentikasi Registry)
Jalankan perintah ini sekali di terminal server untuk mengizinkan server mengunduh image aplikasi dari vendor:

```bash
echo "TOKEN_YANG_DIBERIKAN_VENDOR" | docker login ghcr.io -u utmdev --password-stdin
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
1. **URL Portal Web**: `http://<IP_SERVER_ANDA>:<WEB_PORT>` (Login awal: `admin` / `admin`).
2. **API Key SIMRS**: Diberikan kepada tim pengembang SIMRS pada header `X-SIMRS-API-Key`.

---

## 🌐 Panduan Pengaturan Port (File `.env`)

Jika server rumah sakit Anda sudah menjalankan aplikasi lain (misal web server Apache/Nginx atau database PostgreSQL lain), Anda dapat menyesuaikan port di file `.env`:

| Variabel di `.env` | Default | Status | Keterangan & Panduan |
|---|---|---|---|
| `WEB_PORT` | `80` | ✅ **Boleh Diubah** | Port web portal dashboard yang diakses dari browser pengguna/admin (misal: ubah ke `9191` jika port 80 sudah dipakai Apache/Nginx server RS). Akses menjadi: `http://<IP_SERVER>:9191` |
| `API_PORT` | `3000` | ✅ **Boleh Diubah** | Port host untuk REST API backend (misal: ubah ke `9192` jika port 3000 sudah dipakai service lain). |
| `DB_PORT` | `5432` | ✅ **Boleh Diubah** | Port host PostgreSQL jika menggunakan database bawaan container (misal: ubah ke `9193` jika host server RS sudah memiliki service PostgreSQL lokal). |

> ⚠️ **PENTING: Aturan Koneksi Database Internal (`DATABASE_URL`)**:
> - Perubahan `DB_PORT` di atas **hanya mengubah port yang terekspos ke host luar**.
> - Di dalam Docker Network internal, aplikasi backend tetap menghubungi database pada port default **5432** (`postgresql:5432`).
> - **Jangan mengubah port 5432 pada variabel `DATABASE_URL`** jika menggunakan database bawaan container, contoh yang benar:
>   ```ini
>   DATABASE_URL=postgresql://satusehat_user:PASSWORD@postgresql:5432/satusehat_engine
>   ```

---

## 🛠️ Perintah Operasional Harian
* **Cek Status Service**: `docker compose ps`
* **Melihat Log Aplikasi**: `docker compose logs -f`
* **Melihat Log Service Tertentu**: `docker compose logs -f backend` atau `docker compose logs -f worker`
* **Restart Aplikasi**: `docker compose restart`
* **Stop Aplikasi**: `docker compose down`

> ℹ️ **Fitur Auto-Update**: Aplikasi ini dilengkapi dengan *Watchtower*. Setiap kali vendor merilis perbaikan/fitur baru, aplikasi akan otomatis terupdate di server Anda secara berkala tanpa perlu instalasi ulang.
