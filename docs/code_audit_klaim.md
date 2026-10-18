# Code Audit: Module B (Klaim) & Tests

Audit ini mengevaluasi kualitas kode pada modul `lib/features/klaim` dan berkas pengujian terkait di `test/` berdasarkan pedoman arsitektur dan aturan implementasi di `docs/ui_rules.md`. Temuan di bawah ini diurutkan berdasarkan dampak dan nilai refaktor (ranked by value).

---

## Ringkasan Temuan Audit

| No | Kategori | Berkas & Baris | Tingkat Keparahan |
|---|---|---|---|
| 1 | UI Berisi Business Logic | `lib/features/klaim/presentation/claim_history_screen.dart:65-78` | Tinggi |
| 2 | Hard-Coded Hex Colors (Pelanggaran Aturan Tema) | `lib/features/klaim/presentation/claim_form_sheet.dart:702-770`, `claim_decision_sheet.dart:508`, `claim_status_badge.dart:182-256` | Tinggi |
| 3 | Duplikasi Mapping Status ke Warna & Label | `lib/features/klaim/presentation/widgets/claim_status_badge.dart:23-339`, `claim_detail_screen.dart:552-631` | Sedang-Tinggi |
| 4 | Inkonsistensi & Duplikasi Perhitungan Bisnis (Carbon Savings) | `lib/features/klaim/logic/claim_history_controller.dart:65`, `claim_detail_controller.dart:77`, `claim_form_controller.dart:42`, `claim_detail_screen.dart:1023` | Sedang |
| 5 | Build Method Lebih dari 60 Baris (Monolithic Widgets) | `lib/features/klaim/presentation/claim_detail_screen.dart:809-992, 1008-1202`, `claim_history_screen.dart:318-513`, `claim_card.dart:68-236` | Sedang |
| 6 | Duplikasi Widget Fallback Foto & Maskot | `lib/features/klaim/presentation/claim_form_sheet.dart:421-438`, `claim_detail_screen.dart:786-799`, `claim_card.dart:239-250` | Sedang |
| 7 | Duplikasi Factory Test Fixture di 6 Berkas Test | `test/claim_repository_test.dart:11-33`, `claim_form_test.dart:16-36`, `claim_detail_test.dart:16-36`, dkk. | Sedang |
| 8 | BuildContext & UI Side-Effects Digabungkan ke Controller | `lib/features/klaim/logic/claim_tab_controller.dart:126-206` | Sedang |
| 9 | Duplikasi Pemformat Waktu & Inkonsistensi Kode Transaksi | `lib/features/klaim/presentation/claim_detail_screen.dart:1009-1018, 1244`, `claim_card.dart:34-65`, `incoming_claim_row.dart:20-24` | Rendah-Sedang |
| 10 | Parameter API Bertipe `dynamic` pada Bottom Sheet Publik | `lib/features/klaim/presentation/claim_decision_sheet.dart:21-36` | Rendah |

---

## Rincian Temuan

### 1. UI Widget Menginstansiasi dan Memalsukan Entity Domain
- **Berkas & Baris**: [`lib/features/klaim/presentation/claim_history_screen.dart:65-78`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/claim_history_screen.dart#L65-L78)
- **Masalah**: Method `build` pada UI secara langsung menginstansiasi dan merekayasa entity domain `FoodListing` dengan data tiruan (`FoodListing(...)`) ketika listing tidak ditemukan di repository, melanggar pemisahan tanggung jawab antara presentation layer dan business layer.
- **Refactoring**: Pindahkan resolusi fallback listing ke dalam `ClaimHistoryController` (misalnya method `controller.resolveListing(claim.listingId)` atau kembalikan model tampilan/placeholder resmi dari repository/controller).
- **Risiko**: Rendah. Perubahan murni pada presentation logic tanpa dampak pada skema penyimpanan data.

---

### 2. Hard-Coded Hex Colors Melanggar Design Token Aturan UI
- **Berkas & Baris**: [`lib/features/klaim/presentation/claim_form_sheet.dart:702-770`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/claim_form_sheet.dart#L702-L770), [`lib/features/klaim/presentation/claim_decision_sheet.dart:508`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/claim_decision_sheet.dart#L508), [`lib/features/klaim/presentation/claim_detail_screen.dart:173, 836, 1228`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/claim_detail_screen.dart#L173), [`lib/features/klaim/presentation/widgets/claim_status_badge.dart:182-256`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/widgets/claim_status_badge.dart#L182-L256)
- **Masalah**: Terdapat puluhan penulisan warna hexadecimal langsung seperti `Color(0x3379F3EA)`, `Color(0xFFE5F4FF)`, dan `Color(0xFF7CF6ED)` di dalam berkas UI alih-alih menggunakan token tema dari `AppColors`, melanggar aturan eksplisit pada `docs/ui_rules.md` (Rule 23).
- **Refactoring**: Tambahkan seluruh nilai warna yang berulang tersebut ke dalam [`lib/core/theme/app_colors.dart`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/core/theme/app_colors.dart) dengan penamaan token semantik, kemudian ganti pemanggilan inline `Color(...)` di komponen klaim.
- **Risiko**: Rendah. Memastikan konsistensi desain sistem dan mempermudah pemeliharaan tema aplikasi.

---

### 3. Duplikasi Mapping Status ke Warna & Label di Beberapa Tempat
- **Berkas & Baris**: [`lib/features/klaim/presentation/widgets/claim_status_badge.dart:23-172`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/widgets/claim_status_badge.dart#L23-L172), [`lib/features/klaim/presentation/widgets/claim_status_badge.dart:176-339`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/widgets/claim_status_badge.dart#L176-L339), [`lib/features/klaim/presentation/claim_detail_screen.dart:552-631`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/claim_detail_screen.dart#L552-L631)
- **Masalah**: Pemetaan `ClaimStatus` ke teks label, warna latar belakang, warna teks, dan ikon diulang melalui statement `switch` terpisah di `ClaimStatusBadge` (varian normal dan riwayat) serta `_StatusHeroCard._getHeroConfig`, mengakibatkan logika tampilan terpecah dan rawan inkonsistensi saat status baru ditambahkan.
- **Refactoring**: Buat extension atau helper model tampilan terpusat pada enum `ClaimStatus` (misal `ClaimStatusPresentation` dengan getter `label`, `backgroundColor`, `foregroundColor`, `icon`) dan konsumsi secara seragam pada seluruh badge dan kartu detail.
- **Risiko**: Rendah hingga Sedang. Membutuhkan sinkronisasi seluruh pemanggil badge agar varian visual (standar vs histori) tetap identik.

---

### 4. Inkonsistensi & Duplikasi Perhitungan Bisnis (Carbon Savings)
- **Berkas & Baris**: [`lib/features/klaim/logic/claim_history_controller.dart:65`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/logic/claim_history_controller.dart#L65), [`lib/features/klaim/logic/claim_detail_controller.dart:77`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/logic/claim_detail_controller.dart#L77), [`lib/features/klaim/logic/claim_form_controller.dart:42`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/logic/claim_form_controller.dart#L42), [`lib/features/klaim/presentation/claim_detail_screen.dart:1023`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/claim_detail_screen.dart#L1023)
- **Masalah**: Perhitungan dampak emisi karbon menggunakan angka ajaib (*magic numbers*) yang tidak konsisten antar modul (`1.4` kg/porsi pada detail dan form klaim, tetapi `0.4` kg/porsi pada riwayat klaim) serta dihitung ulang secara manual di dalam method build `_TimeAndCodeCard` alih-alih memanfaatkan properti controller.
- **Refactoring**: Definisikan konstanta global tunggal (misal `kCarbonSavedKgPerPortion = 1.4`) pada core domain, gunakan konstanta tersebut di seluruh controller, dan ubah `_TimeAndCodeCard` agar membaca nilai langsung dari controller.
- **Risiko**: Rendah. Menghilangkan angka kontradiktif yang ditampilkan kepada pengguna pada layar yang berbeda.

---

### 5. Build Methods Sangat Panjang (>60 Baris) pada Komponen Tampilan
- **Berkas & Baris**: [`lib/features/klaim/presentation/claim_detail_screen.dart:809-992`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/claim_detail_screen.dart#L809-L992) (184 baris), [`lib/features/klaim/presentation/claim_detail_screen.dart:1008-1202`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/claim_detail_screen.dart#L1008-L1202) (195 baris), [`lib/features/klaim/presentation/claim_history_screen.dart:318-513`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/claim_history_screen.dart#L318-L513) (196 baris), [`lib/features/klaim/presentation/widgets/claim_card.dart:68-236`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/widgets/claim_card.dart#L68-L236) (169 baris)
- **Masalah**: Beberapa class widget privat memiliki method `build` monolitik antara 100 hingga 195 baris dengan nesting hirarki widget yang sangat dalam, mempersulit pembacaan kode dan melanggar pedoman arsitektur untuk memecah method build besar.
- **Refactoring**: Ekstraksi bagian komponen struktural menjadi sub-widget privat mandiri (misalnya `_PickupPointMapPreview`, `_ClaimTransactionCodeRow`, `_RewardProgressHeader`, dan `_CarbonSavingBanner`).
- **Risiko**: Rendah. Murni refaktorisasi komposisi widget tanpa mengubah perilaku runtime.

---

### 6. Duplikasi Logika Widget Fallback Foto dan Gambar Maskot
- **Berkas & Baris**: [`lib/features/klaim/presentation/claim_form_sheet.dart:421-438`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/claim_form_sheet.dart#L421-L438), [`lib/features/klaim/presentation/claim_detail_screen.dart:786-799`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/claim_detail_screen.dart#L786-L799), [`lib/features/klaim/presentation/widgets/claim_card.dart:239-250`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/widgets/claim_card.dart#L239-L250)
- **Masalah**: Method bantuan `_buildPhoto` / `_buildFallbackPhoto` yang memvalidasi `File(path).existsSync()` dan merender kontainer placeholder ikon `restaurant_rounded` atau `fastfood_rounded` diduplikasi di tiga berkas berbeda.
- **Refactoring**: Buat satu komponen reusable `ListingThumbnailImage` di `lib/core/widgets/` atau `lib/features/donasi/presentation/widgets/` untuk menangani pemuatan gambar file lokal, aset, serta placeholder seragam saat gambar kosong atau gagal dimuat.
- **Risiko**: Rendah. Mengurangi duplikasi kode dan menyatukan perlakuan error image handling.

---

### 7. Duplikasi Fungsi Pembuatan Test Fixture pada 6 Berkas Pengujian
- **Berkas & Baris**: [`test/claim_repository_test.dart:11-33`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/test/claim_repository_test.dart#L11-L33), [`test/claim_form_test.dart:16-36`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/test/claim_form_test.dart#L16-L36), [`test/claim_detail_test.dart:16-36`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/test/claim_detail_test.dart#L16-L36), [`test/claim_decision_sheet_test.dart:14-34`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/test/claim_decision_sheet_test.dart#L14-L34), [`test/claim_history_test.dart:14-34`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/test/claim_history_test.dart#L14-L34), [`test/claim_notification_mapper_test.dart:15-37`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/test/claim_notification_mapper_test.dart#L15-L37)
- **Masalah**: Fungsi factory pembantu `makeTestListing` disalin-tempel identik di 6 berkas test unit dan widget, menimbulkan beban pemeliharaan tinggi jika model `FoodListing` mengalami penambahan atribut baru di kemudian hari.
- **Refactoring**: Ekstraksi fungsi factory fixture tersebut ke berkas utilitas bersama seperti `test/helpers/claim_test_fixtures.dart` dan import ke masing-masing berkas pengujian.
- **Risiko**: Rendah. Pengujian tetap berjalan tanpa perubahan logika asersi dan tidak berdampak ke kode produksi.

---

### 8. `BuildContext` dan UI Side-Effects Digabungkan Langsung ke Controller
- **Berkas & Baris**: [`lib/features/klaim/logic/claim_tab_controller.dart:126-206`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/logic/claim_tab_controller.dart#L126-L206)
- **Masalah**: Method controller seperti `cancelClaim`, `simulateAccept`, `simulateReject`, `simulateIncomingClaim`, dan `triggerReminder` menerima parameter `BuildContext context` dan mengeksekusi `ScaffoldMessenger.of(context).showSnackBar` secara langsung, merusak pemisahan tanggung jawab (*Clean Architecture*).
- **Refactoring**: Hapus ketergantungan `BuildContext` dari controller; biarkan controller mengembalikan objek hasil operasi (seperti `ClaimResult` atau `bool`) dan biarkan widget pemanggil di presentation layer yang menampilkan SnackBar sesuai feedback hasil tersebut.
- **Risiko**: Rendah. Memudahkan unit testing controller tanpa harus menyimulasikan widget tree atau membungkus `BuildContext`.

---

### 9. Inkonsistensi Format Kode Transaksi dan Pengulangan Format Jam
- **Berkas & Baris**: [`lib/features/klaim/presentation/claim_detail_screen.dart:1009-1018, 1244`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/claim_detail_screen.dart#L1009-L1018), [`lib/features/klaim/presentation/widgets/claim_card.dart:34-65`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/widgets/claim_card.dart#L34-L65), [`lib/features/klaim/presentation/widgets/incoming_claim_row.dart:20-24`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/widgets/incoming_claim_row.dart#L20-L24)
- **Masalah**: Pemformatan kode transaksi klaim tidak seragam (`#BGR-` di `claim_detail_screen.dart` vs `#BR-` di `claim_card.dart`), serta helper pemformat waktu jam/menit (`_formatTime` dan `_pad`) diimplementasikan secara ad-hoc berulang kali di berbagai widget.
- **Refactoring**: Sediakan helper terpusat (misal `ClaimFormatters.claimCode(String id)` dan `ClaimFormatters.time(DateTime dt)`) di modul utilitas atau extension method.
- **Risiko**: Rendah. Menyelaraskan teks representasi kode transaksi di seluruh alur pengguna.

---

### 10. Parameter `dynamic` pada Fungsi Publik Entry Point Decision Sheet
- **Berkas & Baris**: [`lib/features/klaim/presentation/claim_decision_sheet.dart:21-36`](file:///c:/Users/USER/KULIAH/Semester%205/Pemrograman%20Teknologi%20Bergerak/frontend/lib/features/klaim/presentation/claim_decision_sheet.dart#L21-L36)
- **Masalah**: Fungsi entry point `showClaimDecisionSheet` menerima parameter `dynamic decision` untuk mengakomodasi pemanggil lama (menerima `ClaimDecision` atau boolean `true`/`false`), yang mengaburkan kontrak tipe data statis Dart dan memicu potensi runtime type error jika nilai tak terduga diberikan.
- **Refactoring**: Ketatkan tipe parameter menjadi `required ClaimDecision decision` dan refactor seluruh tempat pemanggilan yang masih mengoper boolean agar langsung menggunakan enum `ClaimDecision`.
- **Risiko**: Rendah. Membutuhkan verifikasi pada pemanggil layar lama agar tidak ada compile error saat signature diperketat.

