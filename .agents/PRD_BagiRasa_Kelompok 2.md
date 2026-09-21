## PROJECT PRD

Product Requirements Document

| Project Name | BagiRasa – Aplikasi Penyaluran dan Manajemen Makanan |
| --- | --- |
|   | Sisa Berbasis Lokasi |
| Team | 1. Trilen Surya Ningsih (2311522004) |
|   | 2. Dimas Radhitya (2311523026) |
|   | 3. Larisa Alifia Handini (2411523026) |
| Course | Mobile Programming |
| Version | 1.0 |
| Date | 12 September 2026 |

## Tujuan dokumen

PRD ini digunakan untuk menjelaskan apa yang akan dibangun, untuk siapa, mengapa produk dibutuhkan, dan kebutuhan utama dari produk BagiRasa. PRD tidak menjelaskan detail implementasi kode.

## 1. Problem & Users

## 1.1 Problem Statement

Banyak makanan sisa/surplus dari kantin, warung, dan individu di lingkungan kampus yang masih layak konsumsi namun berakhir terbuang, sementara di sisi lain terdapat mahasiswa dan masyarakat sekitar yang membutuhkan akses terhadap makanan tersebut tanpa mekanisme penyaluran yang cepat dan tepat waktu.

## 1.2 Target Users

- Mahasiswa dan pemilik kantin/warung/UMKM di sekitar kampus sebagai pendonor utama makanan surplus.

- Mahasiswa dan staf kampus yang membutuhkan akses makanan sebagai penerima utama.

## 1.3 User Needs / Pain Points

- Pemilik kantin/warung kesulitan menyalurkan makanan sisa yang masih layak sebelum kadaluarsa ataupun tutup toko.

- Mahasiswa/masyarakat yang membutuhkan tidak memiliki informasi real-time mengenai makanan surplus yang tersedia di sekitar mereka.

- Belum ada platform terpusat yang menghubungkan donasi makanan dengan lokasi dan waktu pengambilan yang jelas.

## 1.4 Project Goal

Menyediakan platform mobile yang mempertemukan pendonor dan penerima makanan surplus secara cepat dan berbasis lokasi untuk mengurangi food waste di lingkungan kampus.


## 2. Product Requirements

## 2.1 Functional Requirements

FR-01: Pengguna dapat membuat listing donasi makanan (nama makanan, jumlah porsi, foto, batas waktu ambil).

FR-02: Pengguna dapat mencari dan memfilter listing makanan berdasarkan lokasi dan waktu tersisa.

FR-03: Pengguna dapat mengajukan klaim terhadap listing makanan yang tersedia.

FR-04: Pengguna (pemilik listing) dapat menerima atau menolak klaim yang masuk.

FR-05: Sistem menampilkan lokasi pengambilan makanan pada peta beserta estimasi jarak.

FR-06: Sistem mengirimkan notifikasi terkait listing baru, status klaim, dan pengingat waktu pengambilan.

FR-07: Status listing berubah otomatis (tersedia → habis diklaim → kadaluarsa) berdasarkan waktu dan klaim yang masuk.

FR-08: Pengguna dapat melihat riwayat donasi dan klaim yang pernah dilakukan.

## 2.2 Non-functional Requirements

NFR-01: Halaman utama (listing terdekat) dapat ditampilkan dalam ≤ 3 detik pada kondisi jaringan normal.

NFR-02: Antarmuka dapat digunakan dengan mudah oleh pengguna umum tanpa pelatihan khusus.

NFR-03: Aplikasi dapat berjalan pada perangkat Android minimal versi 8.0 (Oreo) ke atas.

NFR-04: Data lokasi dan kontak pengguna tidak ditampilkan ke pengguna lain tanpa konteks transaksi yang relevan (misal setelah klaim disetujui).

NFR-05: Notifikasi pengingat waktu pengambilan terkirim maksimal 5 menit setelah kondisi terpenuhi.

## 2.3 Core Features

Enam fitur inti yang diperlukan untuk menyelesaikan masalah, konsisten dengan functional requirements di atas:

| No. | Core Feature | Purpose / Value |
| --- | --- | --- |
| 1 | Buat Listing Donasi | Memungkinkan pendonor membagikan makanan |
|   |   | surplus secara cepat dengan info lengkap (foto, |
|   |   | jumlah, batas waktu ambil). |
| 2 | Pencarian & Filter Listing Membantu penerima menemukan makanan surplus |   |
|   |   | terdekat sesuai lokasi dan waktu tersisa. |
| 3 | Klaim & Approval | Memastikan proses pengambilan makanan |
|   |   | terorganisir dan disetujui oleh pemilik listing. |


| 4 | Peta & Lokasi | Memudahkan penerima menemukan dan menuju |
| --- | --- | --- |
|   | Pengambilan | lokasi pengambilan makanan. |
| 5 | Notifikasi Real-time | Menjaga pengguna tetap mendapat info terbaru soal |
|   |   | listing baru, status klaim, dan waktu pengambilan. |
| 6 | Riwayat & Statistik | Menunjukkan dampak nyata (jumlah porsi makanan |
|   |   | terselamatkan) bagi pengguna. |

## 2.4 User Flow

Open App (Home) → Pilih “Donasikan” atau “Cari Makanan” →

Jalur Donasi: Buat Listing → Tentukan Lokasi Pengambilan → Terima/Tolak Klaim Masuk → Status Listing Selesai

Jalur Klaim: Lihat Listing di Peta → Ajukan Klaim → Terima Konfirmasi → Datang ke Lokasi Pengambilan

Kedua jalur bermuara ke: Riwayat & Statistik Aktivitas Pengguna.

## 2.5 Data Requirements

| Data / Entity | Key Information | Purpose |
| --- | --- | --- |
| User | id, nama, email, foto profil, lokasi | Identitas pengguna untuk |
|   | default | aktivitas donasi & klaim (1 |
|   |   | akun, 2 aktivitas) |
| Listing (Donation) | id, donor_id, nama makanan, jumlah | Menyimpan data makanan |
|   | porsi, foto, lokasi, batas waktu | yang didonasikan |
|   | ambil, status |   |
| Claim | id, donation_id, claimer_id, jumlah | Mencatat transaksi klaim |
|   | diklaim, status approval, waktu | terhadap listing |
|   | klaim |   |
| Notification | id, user_id, tipe notifikasi, isi pesan, | Mengelola pengiriman |
|   | status baca, waktu kirim | notifikasi ke pengguna |

## 2.6 Constraints & Assumptions

- Aplikasi dikembangkan menggunakan Flutter dengan database non-Firebase (SQLite lokal atau server MySQL/PostgreSQL).

- Diasumsikan pengguna memiliki koneksi internet aktif saat menggunakan fitur lokasi dan notifikasi.

- Cakupan awal (MVP) difokuskan pada lingkungan kampus dan sekitarnya, belum mendukung skala besar.

- Tim terdiri dari 3 anggota dengan pembagian modul: Donasi Makanan, Permintaan & Klaim, serta Titik Pengambilan & Lokasi.

- Waktu pengembangan dibatasi selama 6 minggu sesuai timeline mata kuliah.


## 2.7 Success Criteria

- Aplikasi dapat menjalankan alur end-to-end: buat listing → klaim → approval → pengambilan, tanpa error kritis.

- Minimal 3 functional module (CRUD, notifikasi, fitur device) terintegrasi dan dapat didemokan.

- Pengguna uji coba (tim/teman) dapat menyelesaikan alur donasi/klaim tanpa instruksi tambahan.

- Waktu respons antar modul (listing → notifikasi → klaim) berjalan sesuai NFR yang ditetapkan.

## 3. Scope

## 3.1 In Scope

- Pembuatan, pencarian, dan pengelolaan listing donasi makanan.

- Proses klaim dan approval antar pengguna.

- Peta lokasi pengambilan dan estimasi jarak.

- Notifikasi terkait listing baru, status klaim, dan pengingat waktu ambil.

- Riwayat aktivitas donasi dan klaim pengguna.

## 3.2 Out of Scope

- Sistem pembayaran atau transaksi uang (aplikasi bersifat donasi, bukan jual-beli).

- Verifikasi identitas/KYC pengguna secara formal.

- Fitur rating/review antar pengguna (di luar scope MVP).

- Dukungan multi-bahasa atau ekspansi ke luar lingkungan kampus.

## 4. AI Prompt Context

BagiRasa adalah aplikasi mobile berbasis Flutter yang menghubungkan pendonor makanan surplus (kantin, warung, individu di lingkungan kampus) dengan penerima yang membutuhkan untuk mengurangi food waste (selaras dengan SDG 2 dan SDG 12). Target pengguna adalah mahasiswa, staf kampus, dan pemilik UMKM di sekitar kampus. Terdapat 1 jenis akun pengguna yang dapat melakukan dua aktivitas: donasi dan klaim (bukan role terpisah). Core features: buat listing donasi, pencarian dan filter listing, klaim dan approval, peta lokasi pengambilan, notifikasi real-time, serta riwayat dan statistik. Constraint: dibangun dengan Flutter, database non-Firebase (SQLite/PostgreSQL/MySQL), tanpa sistem pembayaran, dikembangkan oleh tim 3 orang dalam waktu 6 minggu. Output yang diharapkan dari AI: bantuan desain struktur data, potongan kode Flutter per modul (donasi, klaim, lokasi), serta saran UX yang konsisten dengan konsep 1 user + 2 aktivitas.

## PRD Checklist

- Problem statement jelas dan berfokus pada pengguna.

- Target users spesifik.

- Project goal menjawab masalah yang diidentifikasi.


Core features berjumlah 6 dan relevan.

User flow utama sudah dituliskan.

Data utama sudah diidentifikasi.

Constraints dan assumptions sudah dicatat.

Success criteria dapat digunakan untuk menilai hasil project.

In Scope dan Out of Scope sudah jelas.

Functional requirements menjelaskan perilaku/fungsi yang harus dilakukan aplikasi.

Non-functional requirements menjelaskan kualitas/batasan sistem dan dapat diukur.

Functional requirements konsisten dengan core features.

Non-functional requirements tidak ditulis sebagai fitur baru.
