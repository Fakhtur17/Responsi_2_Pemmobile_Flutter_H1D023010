# responsi2_mobile_paket1_h1d023010

# README – Aplikasi Inventaris Komputer

Responsi 2 Mobile Paket 1 – Flutter + REST API

---

## Identitas

Aplikasi ini dibuat untuk memenuhi tugas **Responsi 2 Mobile Paket 1**.

* **Nama**  : Ramadhan Fakhtur Rakhman
* **NIM**   : H1D023010
* **Shift baru** : `Shift … (isi sesuai)`
* **Shift asal** : `Shift … (isi sesuai)`
* **Video demo aplikasi** : `https://youtu.be/… (isi link demo YouTube / GDrive)`

README ini menjelaskan alur kerja aplikasi, spesifikasi API yang digunakan, serta penjelasan kode untuk setiap fungsi utama di dalam aplikasi.

---

## Deskripsi Singkat Aplikasi

Aplikasi **Inventaris Komputer Ramadhan Fakhtur Rakhman** adalah aplikasi mobile berbasis **Flutter** yang terhubung dengan REST API (Laravel / backend lain) untuk mengelola data inventaris peralatan komputer. Pengguna harus melakukan **registrasi** dan **login** terlebih dahulu untuk mendapatkan token. Setelah login, pengguna dapat:

* Melihat daftar inventaris komputer.
* Menambah data barang baru.
* Mengubah data barang yang sudah ada.
* Menghapus barang dari daftar inventaris.
* Logout dan menghapus data sesi yang tersimpan di perangkat.

Autentikasi di sisi mobile menggunakan **token Bearer** yang dikirimkan pada setiap request ke endpoint inventaris.

---

## Alur Aplikasi (Flow) Secara Naratif

Saat aplikasi pertama kali dijalankan, `main.dart` akan memanggil widget `ResponsiApp`. Di dalam `ResponsiApp`, aplikasi memeriksa apakah sudah ada **token**, **name**, dan **email** yang tersimpan di `SharedPreferences` melalui fungsi `_checkLogin()`. Jika data login masih tersimpan dan token tidak kosong, pengguna akan langsung diarahkan ke halaman **HomePage** tanpa perlu login ulang. Jika tidak ada data login, maka yang ditampilkan adalah halaman **LoginPage**.

Pada **halaman Login**, pengguna diminta mengisi email dan password. Ketika tombol **LOGIN** ditekan, fungsi `_doLogin()` akan dipanggil. Fungsi ini akan memanggil `ApiService.login()`, mengirimkan email dan password ke endpoint `/login`. Jika server mengembalikan status sukses, aplikasi mengambil data **token**, **name**, dan **email** dari response, lalu menyimpannya ke `SharedPreferences`. Setelah itu pengguna dialihkan ke halaman **HomePage**, yang memuat daftar inventaris milik pengguna.

Jika pengguna belum punya akun, mereka bisa menekan tombol **Registrasi** pada halaman login. Tombol tersebut membuka **RegisterPage**. Di halaman ini, pengguna mengisi nama, email, dan password. Saat tombol **REGISTER** ditekan, fungsi `_doRegister()` di `RegisterPage` akan memanggil `ApiService.register()`, mengirim data ke endpoint `/register`. Jika berhasil, aplikasi akan menampilkan pesan bahwa registrasi berhasil dan secara otomatis kembali ke halaman login sehingga pengguna bisa langsung login dengan akun baru.

Pada **HomePage**, segera setelah widget dibuat, fungsi `_loadData()` dijalankan di `initState()`. Fungsi ini memanggil `ApiService.getInventories()` dengan membawa token yang dimiliki pengguna. Respon dari API berupa list data inventaris kemudian dikonversi menjadi list `Inventory` dan ditampilkan dalam bentuk kartu (Card) di dalam `ListView`. Jika belum ada data inventaris, halaman akan menampilkan pesan bahwa belum ada data dan mengarahkan pengguna untuk menekan tombol tambah.

Untuk **menambah data**, pengguna menekan **FloatingActionButton** “Tambah”. Tombol ini membuka halaman **InventoryFormPage** tanpa membawa data awal. Di form ini, pengguna mengisi nama barang, harga, jumlah, dan tanggal masuk (tanggal bisa dipilih dari date picker). Saat tombol **SIMPAN** ditekan, fungsi `_submit()` akan mengemas input menjadi objek `Inventory` (sementara) dan mengembalikannya ke `HomePage` melalui `Navigator.pop`. Di `HomePage`, fungsi `_addItem()` akan menerima objek `Inventory` tersebut dan memanggil `ApiService.createInventory()`. Jika API menyimpan data berhasil, aplikasi memanggil kembali `_loadData()` untuk me-refresh daftar inventaris.

Untuk **mengedit data**, pengguna bisa mengetuk salah satu kartu item inventaris atau memilih menu **Edit** dari menu titik tiga di sisi kanan item. Kedua cara ini akan memanggil `InventoryFormPage` namun kali ini membawa objek `Inventory` yang akan diedit. Form akan terisi otomatis dengan nilai awal dari barang tersebut. Setelah pengguna mengubah data dan menekan tombol **SIMPAN PERUBAHAN**, fungsi `_submit()` mengembalikan objek `Inventory` yang baru ke `HomePage`, lalu `_editItem()` akan membuat objek baru dengan `id` yang sama namun data terbarui, dan memanggil `ApiService.updateInventory()`. Jika berhasil, data di server diperbarui dan `_loadData()` dipanggil ulang.

Untuk **menghapus data**, pengguna menekan menu titik tiga di item lalu memilih **Hapus**. Fungsi `_deleteItem()` akan menampilkan dialog konfirmasi. Jika pengguna menekan **HAPUS**, aplikasi memanggil `ApiService.deleteInventory()` menggunakan `id` barang tersebut. Bila API mengembalikan status berhasil, daftar inventaris kembali dimuat ulang sehingga item yang dihapus tidak lagi ditampilkan.

Pada bagian **logout**, ikon logout berada di sisi kanan AppBar pada `HomePage`. Ketika tombol ini ditekan, fungsi `_logout()` akan menghapus semua data yang tersimpan di `SharedPreferences` (token, nama, email), lalu menavigasikan pengguna kembali ke **LoginPage** dengan mengganti seluruh stack halaman. Dengan demikian, pengguna benar-benar harus login kembali untuk mengakses HomePage.

---

## Spesifikasi API yang Digunakan

Semua permintaan API dilakukan melalui kelas `ApiService` dengan base URL:

```dart
static const String baseUrl = 'http://127.0.0.1:8000/api';
```

> Catatan: Jika dijalankan di Android Emulator yang mengakses server lokal, biasanya `127.0.0.1` perlu diganti menjadi `10.0.2.2` agar emulator bisa mengakses mesin host.

### 1. Registrasi Pengguna

* **Method** : `POST`

* **Endpoint** : `/register`

* **Header** :

  * `Content-Type: application/json`
  * `Accept: application/json`

* **Body (JSON)**:

```json
{
  "name": "Nama Lengkap",
  "email": "user@example.com",
  "password": "password123"
}
```

* **Response Sukses (contoh struktur yang diasumsikan)**:

```json
{
  "status": true,
  "message": "Registrasi berhasil",
  "data": {
    "user": {
      "id": 1,
      "name": "Nama Lengkap",
      "email": "user@example.com"
    }
  }
}
```

* **Perlakuan di aplikasi**: aplikasi hanya mengecek `status == true`. Jika tidak, aplikasi menampilkan pesan error dari `message`.

---

### 2. Login Pengguna

* **Method** : `POST`

* **Endpoint** : `/login`

* **Header** :

  * `Content-Type: application/json`
  * `Accept: application/json`

* **Body (JSON)**:

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

* **Response Sukses (format yang diharapkan oleh AppUser.fromLoginJson)**:

```json
{
  "status": true,
  "message": "Login berhasil",
  "data": {
    "token": "JWT_OR_PERSONAL_ACCESS_TOKEN",
    "user": {
      "id": 1,
      "name": "Nama Lengkap",
      "email": "user@example.com"
    }
  }
}
```

* **Perlakuan di aplikasi**: jika `status != true` atau HTTP status bukan 200, aplikasi melempar exception dengan pesan dari `message`. Jika sukses, data user dan token digunakan untuk membuat objek `AppUser`.

---

### 3. Mendapatkan Daftar Inventaris

* **Method** : `GET`

* **Endpoint** : `/inventories`

* **Header** :

  * `Content-Type: application/json`
  * `Accept: application/json`
  * `Authorization: Bearer {token}`

* **Response Sukses (contoh)**:

```json
{
  "status": true,
  "message": "Data inventaris berhasil diambil",
  "data": [
    {
      "id": 1,
      "nama": "PC Kasir",
      "harga": 2500000,
      "jumlah": 3,
      "tanggal_masuk": "2025-12-01"
    },
    {
      "id": 2,
      "nama": "Monitor 24 inci",
      "harga": 1500000,
      "jumlah": 5,
      "tanggal_masuk": "2025-12-03"
    }
  ]
}
```

`data` harus berupa array yang dapat dikonversi ke model `Inventory`.

---

### 4. Menambah Data Inventaris

* **Method** : `POST`

* **Endpoint** : `/inventories`

* **Header** :

  * `Content-Type: application/json`
  * `Accept: application/json`
  * `Authorization: Bearer {token}`

* **Body (JSON)** – berasal dari `Inventory.toJson()`:

```json
{
  "nama": "PC Kasir",
  "harga": 2500000,
  "jumlah": 3,
  "tanggal_masuk": "2025-12-01"
}
```

* **Response Sukses (contoh)**:

```json
{
  "status": true,
  "message": "Data inventaris berhasil ditambah",
  "data": {
    "id": 1,
    "nama": "PC Kasir",
    "harga": 2500000,
    "jumlah": 3,
    "tanggal_masuk": "2025-12-01"
  }
}
```

---

### 5. Mengubah Data Inventaris

* **Method** : `PUT`

* **Endpoint** : `/inventories/{id}`

* **Header** :

  * `Content-Type: application/json`
  * `Accept: application/json`
  * `Authorization: Bearer {token}`

* **Body (JSON)** – format sama dengan create:

```json
{
  "nama": "PC Kasir Update",
  "harga": 2600000,
  "jumlah": 4,
  "tanggal_masuk": "2025-12-01"
}
```

* **Response Sukses (contoh)**:

```json
{
  "status": true,
  "message": "Data inventaris berhasil diubah",
  "data": {
    "id": 1,
    "nama": "PC Kasir Update",
    "harga": 2600000,
    "jumlah": 4,
    "tanggal_masuk": "2025-12-01"
  }
}
```

---

### 6. Menghapus Data Inventaris

* **Method** : `DELETE`

* **Endpoint** : `/inventories/{id}`

* **Header** :

  * `Accept: application/json`
  * `Authorization: Bearer {token}`

* **Response Sukses (contoh)**:

```json
{
  "status": true,
  "message": "Data inventaris berhasil dihapus"
}
```

Atau server bisa saja mengembalikan HTTP 204 tanpa body. Di sisi client, kode menangani kedua kemungkinan tersebut.

---

## Penjelasan Kode dan Fungsi dalam Aplikasi

### 1. `main.dart` & `ResponsiApp`

Fungsi `main()` hanya memanggil `runApp(const ResponsiApp());` yang akan menjalankan aplikasi Flutter dengan root widget `ResponsiApp`. Di dalam `ResponsiApp`, terdapat fungsi `_checkLogin()` yang bersifat asynchronous. Fungsi ini membaca `SharedPreferences` untuk mengecek apakah sudah ada nilai `token`, `name`, dan `email`. Jika ketiganya ada dan token tidak kosong, `ResponsiApp` membentuk `AppUser` sementara (dengan `id: 0`) dan mengembalikannya sebagai nilai future. Pada method `build()`, `ResponsiApp` menggunakan `FutureBuilder<AppUser?>` untuk menentukan halaman awal: jika future mengembalikan `null` atau user tanpa token, maka yang ditampilkan adalah `LoginPage`; jika ada user valid, aplikasi langsung menampilkan `HomePage(user: user)`.

Selain itu, `ResponsiApp` juga mengatur `ThemeData`, seperti warna utama (`primarySwatch`), warna background scaffold, serta tema AppBar yang konsisten (AppBar berwarna abu gelap dan teks putih).

---

### 2. Model `AppUser`

Kelas `AppUser` merepresentasikan data pengguna yang sedang login. Field yang disimpan adalah `id`, `name`, `email`, dan `token`. Konstruktor biasa digunakan ketika aplikasi membentuk user dari data SharedPreferences. Pabrik `factory AppUser.fromLoginJson(Map<String, dynamic> json)` digunakan untuk membentuk objek `AppUser` langsung dari response login. Fungsi ini mengambil bagian `data` dari JSON, kemudian mengambil `user` di dalamnya, dan mengisi field `id`, `name`, `email`, serta `token` dengan nilai yang diambil dari response. Dengan cara ini, setiap kali login sukses, aplikasi dapat langsung membungkus respons server menjadi objek `AppUser` yang siap digunakan di seluruh aplikasi.

---

### 3. Model `Inventory`

Kelas `Inventory` merepresentasikan satu barang inventaris. Field yang disimpan adalah `id`, `nama`, `harga`, `jumlah`, dan `tanggalMasuk`. Konstruktornya mewajibkan semua field untuk memastikan setiap objek selalu dalam kondisi lengkap (tidak ada field null).

Fungsi `factory Inventory.fromJson(Map<String, dynamic> json)` digunakan untuk mengubah data JSON dari API menjadi objek `Inventory`. Di dalamnya, kode menangani kemungkinan perbedaan tipe data, misalnya `harga` dan `jumlah` bisa saja dikirim sebagai `int` atau `String`. Oleh karena itu, dicek terlebih dahulu apakah `json['harga']` bertipe `int`; jika bukan, nilainya dikonversi menggunakan `int.tryParse()`. Hal yang sama dilakukan pada field `jumlah`. Hal ini membuat aplikasi lebih robust terhadap variasi format response API.

Fungsi `Map<String, dynamic> toJson()` digunakan ketika aplikasi ingin mengirim data ke server, misalnya saat menambah atau mengubah barang. Fungsi ini mengembalikan map dengan key sesuai yang diharapkan oleh API, yaitu `nama`, `harga`, `jumlah`, dan `tanggal_masuk`. Fungsi ini dipakai langsung di `ApiService.createInventory()` dan `ApiService.updateInventory()`.

---

### 4. `ApiService` – Kelas Layanan API

Kelas `ApiService` menjadi satu titik pusat komunikasi dengan server.

* **Fungsi `register(String name, String email, String password)`**
  Fungsi ini membangun `Uri` untuk endpoint `/register`, lalu mengirim request `POST` dengan header `Content-Type: application/json` dan `Accept: application/json`. Body permintaan di-encode sebagai JSON berisi `name`, `email`, dan `password`. Setelah mendapat response, fungsi mem-parsing isi body JSON menjadi `data`. Jika `response.statusCode` bukan 200 atau `data['status']` bukan `true`, fungsi melempar `Exception` dengan pesan dari `data['message']` atau default “Registrasi gagal”. Jika berhasil, fungsi tidak mengembalikan data (void) karena di sisi klien tidak digunakan; yang penting adalah registrasi sukses.

* **Fungsi `login(String email, String password)`**
  Fungsi ini hampir mirip dengan `register`, namun endpoint yang dituju adalah `/login`. Body request berisi `email` dan `password`. Setelah response diterima dan di-parse, jika `status` tidak `true` atau kode status bukan 200, fungsi melempar `Exception` dengan pesan error. Jika sukses, fungsi memanggil `AppUser.fromLoginJson(data)` untuk membentuk objek `AppUser` yang kemudian dikembalikan ke pemanggil.

* **Fungsi privat `_headersWithToken(String token)`**
  Fungsi ini mengembalikan map header standar JSON yang sudah ditambah `Authorization: Bearer {token}`. Fungsi ini digunakan oleh semua fungsi CRUD inventaris agar tidak perlu menulis header berulang-ulang. Dengan cara ini, setiap permintaan ke endpoint inventaris selalu membawa token autentikasi.

* **Fungsi `getInventories(String token)`**
  Fungsi ini membangun request `GET` ke endpoint `/inventories` dengan header yang dihasilkan oleh `_headersWithToken(token)`. Setelah response diterima, body JSON di-parse ke `data`. Jika `status` bukan `true` atau kode status bukan 200, fungsi melempar exception. Jika sukses, fungsi membaca `data['data']` yang diasumsikan sebagai list, lalu memetakan setiap elemen JSON menjadi objek `Inventory` menggunakan `Inventory.fromJson(e)`. Hasil akhir dikembalikan sebagai `List<Inventory>`.

* **Fungsi `createInventory(String token, Inventory inv)`**
  Fungsi ini mengirim request `POST` ke `/inventories` dengan header berisi token dan body JSON dari `inv.toJson()`. Setelah response diterima, JSON di-parse ke `data`. Jika kode status bukan 201 dan bukan 200, maka dianggap gagal dan exception dilempar dengan `data['message']` atau pesan default. Jika sukses, fungsi mengembalikan objek `Inventory` baru yang diambil dari `data['data']`. Ini berguna jika API mengembalikan `id` yang baru dibuat.

* **Fungsi `updateInventory(String token, Inventory inv)`**
  Fungsi ini mengirim request `PUT` ke `/inventories/{inv.id}`. Header dan body request sama seperti create. Setelah response diterima, JSON di-parse ke `data`. Jika `status != true` atau kode status bukan 200, exception dilempar. Karena di sisi klien data pengembalian tidak digunakan, fungsi ini bertipe `Future<void>`.

* **Fungsi `deleteInventory(String token, int id)`**
  Fungsi ini mengirim request `DELETE` ke `/inventories/{id}` dengan header berisi token. Jika kode status bukan 200 dan bukan 204, fungsi mencoba mem-parse body JSON untuk mengambil `message` dari server dan melempar exception. Jika parsing gagal (misalnya server mengembalikan body kosong), fungsi akan melempar exception dengan pesan default “Gagal menghapus data”.

---

### 5. `LoginPage`

`LoginPage` adalah halaman form untuk login pengguna. Variabel `_formKey` menyimpan `GlobalKey<FormState>` untuk validasi form, sedangkan `_emailC` dan `_passwordC` adalah controller teks. `_loading` digunakan untuk menandai status sedang melakukan request ke API agar tombol tidak bisa ditekan berkali-kali.

* **Fungsi `_doLogin()`**
  Pertama, fungsi ini memanggil `_formKey.currentState!.validate()` untuk memastikan email dan password tidak kosong. Jika valid, `_loading` di-set `true` agar UI menampilkan indikator loading dan men-disable tombol login. Fungsi lalu memanggil `_api.login()` dengan email dan password yang sudah di-trim. Jika login berhasil, fungsi menyimpan `token`, `name`, dan `email` ke `SharedPreferences`. Setelah itu, jika widget masih terpasang (`mounted` true), navigasi diganti menggunakan `Navigator.pushReplacement` ke `HomePage(user: user)`. Jika terjadi error (misal email/password salah), exception ditangkap di blok `catch` dan `SnackBar` ditampilkan di layar dengan isi pesan error. Pada blok `finally`, `_loading` di-set kembali menjadi `false` selama widget masih mounted sehingga tampilan tombol kembali normal.

UI dari `LoginPage` terdiri dari **AppBar** dengan judul aplikasi inventaris, kemudian body yang berisi Card dengan form input email, password, tombol login, dan teks + tombol kecil untuk menuju halaman registrasi.

---

### 6. `RegisterPage`

`RegisterPage` sangat mirip pola kerjanya dengan `LoginPage`. Di sini terdapat controller `_nameC`, `_emailC`, dan `_passwordC`, serta `_loading`.

* **Fungsi `_doRegister()`**
  Fungsi ini memvalidasi form terlebih dahulu. Jika semua field terisi, `_loading` di-set menjadi `true` dan `_api.register()` dipanggil dengan nama, email, dan password yang sudah di-trim. Jika server mengembalikan status sukses, fungsi menampilkan `SnackBar` dengan pesan “Registrasi berhasil, silakan login” dan kemudian memanggil `Navigator.pop(context)` sehingga halaman registrasi ditutup dan pengguna kembali ke halaman login. Jika terjadi error (misalnya email sudah dipakai), exception ditangkap dan ditampilkan lewat `SnackBar`. Di blok `finally`, `_loading` dikembalikan ke `false` bila widget masih mounted.

Secara tampilan, `RegisterPage` berisi Card dengan form: input nama, email, dan password, serta tombol **REGISTER** dengan efek loading ketika request sedang diproses.

---

### 7. `HomePage`

`HomePage` menerima parameter `AppUser user` untuk mengetahui token, nama, dan email pengguna yang sedang login. Di dalamnya terdapat `_api` sebagai instance `ApiService`, boolean `_loading` untuk menandai status pemanggilan API, dan list `_items` yang menyimpan daftar `Inventory`.

* **Fungsi `_loadData()`**
  Fungsi ini bertanggung jawab mengambil data inventaris. Pertama, `_loading` diset ke `true` agar UI menampilkan `CircularProgressIndicator` ketika sedang mengambil data. Kemudian fungsi memanggil ` _api.getInventories(widget.user.token)` dan hasilnya disimpan ke `_items` melalui `setState`. Jika terjadi error (misal token invalid atau server error), exception ditangkap dan ditampilkan lewat `SnackBar`. Pada blok `finally`, `_loading` dikembalikan menjadi `false` jika widget masih mounted.

* **Fungsi `_addItem()`**
  Fungsi ini menavigasi ke `InventoryFormPage` tanpa membawa objek `inventory` (artinya mode tambah). `Navigator.push` mengembalikan `Inventory?` ketika halaman form dipop. Jika hasilnya tidak null, berarti pengguna menekan tombol simpan. Kemudian fungsi memanggil ` _api.createInventory(widget.user.token, result)` untuk menyimpan data ke server. Jika sukses, `_loadData()` dipanggil lagi untuk memperbarui daftar di layar. Jika terjadi error, `SnackBar` digunakan untuk menampilkan pesan kesalahan.

* **Fungsi `_editItem(Inventory item)`**
  Mirip dengan `_addItem`, namun kali ini `InventoryFormPage` dipanggil dengan parameter `inventory: item`. Hasil dari form disimpan ke `result`. Jika tidak null, kode membuat objek `updated` yang memiliki `id` sama dengan `item.id` tetapi field lain diisi dari `result`. Objek `updated` kemudian dikirim ke server melalui ` _api.updateInventory(widget.user.token, updated)`. Jika berhasil, `_loadData()` dipanggil ulang.

* **Fungsi `_deleteItem(Inventory item)`**
  Fungsi ini pertama-tama menampilkan `AlertDialog` untuk konfirmasi penghapusan. Jika pengguna menekan tombol HAPUS, maka `ok == true` dan fungsi memanggil `_api.deleteInventory(widget.user.token, item.id)`. Bila server merespons sukses, data di-refresh menggunakan `_loadData()`. Jika terjadi error, pesan error ditampilkan melalui `SnackBar`.

* **Fungsi `_logout()`**
  Fungsi ini membaca `SharedPreferences`, memanggil `clear()` untuk menghapus semua data login, lalu jika widget masih mounted melakukan `Navigator.pushAndRemoveUntil` ke `LoginPage`. Dengan cara ini, user tidak bisa kembali ke HomePage lewat tombol back.

Pada method `build`, `HomePage` menampilkan AppBar dengan judul lengkap aplikasi dan tombol logout. Body menggunakan `SafeArea` dan menampilkan:

* Loading spinner jika `_loading == true`.
* Pesan “Belum ada data inventaris” jika `_items` kosong.
* `RefreshIndicator` yang membungkus `ListView.builder` jika data tersedia. Pengguna bisa menarik ke bawah (pull to refresh) untuk memanggil `_loadData()` kembali.

Setiap item inventaris ditampilkan dalam `Card` dengan `ListTile`, menampilkan huruf pertama nama barang di `CircleAvatar`, detail harga, jumlah, dan tanggal masuk. Menu titik tiga di trailing menggunakan `PopupMenuButton` untuk menampilkan aksi Edit dan Hapus.

---

### 8. `InventoryFormPage`

`InventoryFormPage` digunakan untuk **tambah** maupun **edit** data barang inventaris. Parameter opsional `Inventory? inventory` menentukan apakah form dalam mode edit atau tambah.

Di `initState()`, jika `widget.inventory` tidak null, maka nilai-nilai awal dari nama, harga, jumlah, dan tanggal masuk diisi sesuai objek tersebut. Jika null (tambah data baru), tanggal otomatis diisi dengan tanggal hari ini menggunakan `DateFormat('yyyy-MM-dd').format(DateTime.now())`.

* **Fungsi `_pickDate()`**
  Fungsi ini menampilkan `showDatePicker` untuk memungkinkan pengguna memilih tanggal masuk barang. Nilai `initialDate` di-set ke tanggal saat ini, dengan rentang tahun 2000–2100. Jika pengguna memilih tanggal, hasilnya diformat menjadi string `yyyy-MM-dd` dan diisi ke `_tanggalC`. `setState` dipanggil agar tampilan ter-update.

* **Fungsi `_submit()`**
  Fungsi ini memulai dengan memvalidasi form. Jika ada field wajib yang kosong, form akan menampilkan pesan error. Jika semua valid, fungsi membentuk objek `Inventory` baru dengan:

  * `id`: jika mode edit, memakai `widget.inventory!.id`, jika mode tambah diisi 0 (nanti akan diabaikan oleh server).
  * `nama`: isi dari `_namaC`.
  * `harga`: hasil `int.tryParse` dari `_hargaC`, default 0 jika gagal.
  * `jumlah`: hasil `int.tryParse` dari `_jumlahC`, default 0 jika gagal.
  * `tanggalMasuk`: isi dari `_tanggalC`.

  Objek `inv` kemudian dikembalikan ke halaman sebelumnya dengan `Navigator.pop(context, inv)`. Di `HomePage`, hasil ini akan diterima oleh `_addItem()` atau `_editItem()` tergantung mode pemanggilan.

UI `InventoryFormPage` menghadirkan form yang rapi di dalam Card dengan judul dan deskripsi singkat di bagian atas, beberapa input field dengan hint yang membantu, serta tombol simpan di bagian bawah yang menampilkan teks “SIMPAN PERUBAHAN” jika edit dan “SIMPAN” jika tambah.

---

## Penutup

README ini menjelaskan:

* Identitas pembuat (nama, NIM, shift baru & shift asal).
* Gambaran umum dan alur kerja aplikasi Inventaris Komputer.
* Spesifikasi API yang digunakan untuk autentikasi dan CRUD data inventaris.
* Penjelasan per fungsi utama dalam kelas-kelas penting: `AppUser`, `Inventory`, `ApiService`, `LoginPage`, `RegisterPage`, `HomePage`, dan `InventoryFormPage`.

Silakan melengkapi bagian **Shift baru**, **Shift asal**, dan **link video demo aplikasi** sesuai ketentuan tugas. Jika backend (API) memiliki response yang sedikit berbeda, pastikan struktur JSON yang dikirim dan diterima telah disesuaikan dengan model dan `ApiService` di aplikasi Flutter ini.

