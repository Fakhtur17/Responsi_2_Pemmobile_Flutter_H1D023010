class Inventory {
  final int id;
  final String nama;
  final int harga;
  final int jumlah;
  final String tanggalMasuk;

  Inventory({
    required this.id,
    required this.nama,
    required this.harga,
    required this.jumlah,
    required this.tanggalMasuk,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      harga: (json['harga'] ?? 0) is int
          ? (json['harga'] ?? 0)
          : int.tryParse(json['harga'].toString()) ?? 0,
      jumlah: (json['jumlah'] ?? 0) is int
          ? (json['jumlah'] ?? 0)
          : int.tryParse(json['jumlah'].toString()) ?? 0,
      tanggalMasuk: json['tanggal_masuk'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'harga': harga,
      'jumlah': jumlah,
      'tanggal_masuk': tanggalMasuk,
    };
  }
}
