import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/inventory.dart';

class InventoryFormPage extends StatefulWidget {
  final Inventory? inventory;

  const InventoryFormPage({super.key, this.inventory});

  @override
  State<InventoryFormPage> createState() => _InventoryFormPageState();
}

class _InventoryFormPageState extends State<InventoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaC = TextEditingController();
  final _hargaC = TextEditingController();
  final _jumlahC = TextEditingController();
  final _tanggalC = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.inventory != null) {
      _namaC.text = widget.inventory!.nama;
      _hargaC.text = widget.inventory!.harga.toString();
      _jumlahC.text = widget.inventory!.jumlah.toString();
      _tanggalC.text = widget.inventory!.tanggalMasuk;
    } else {
      _tanggalC.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  void _pickDate() async {
    final now = DateTime.now();
    final init = now;
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _tanggalC.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final inv = Inventory(
      id: widget.inventory?.id ?? 0,
      nama: _namaC.text.trim(),
      harga: int.tryParse(_hargaC.text.trim()) ?? 0,
      jumlah: int.tryParse(_jumlahC.text.trim()) ?? 0,
      tanggalMasuk: _tanggalC.text.trim(),
    );

    Navigator.pop(context, inv);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.inventory != null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          isEdit
              ? 'Edit Inventaris Ramadhan Fakhtur'
              : 'Tambah Inventaris Ramadhan Fakhtur',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: const Color.fromARGB(255, 110, 110, 110),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Text(
                          isEdit
                              ? 'Ubah data barang inventaris'
                              : 'Isi data barang inventaris',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pastikan data yang diinput sudah benar.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Nama Barang
                        TextFormField(
                          controller: _namaC,
                          decoration: InputDecoration(
                            labelText: 'Nama Barang',
                            hintText: 'Misal: PC Kasir, Monitor, Printer',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Nama wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // Harga
                        TextFormField(
                          controller: _hargaC,
                          decoration: InputDecoration(
                            labelText: 'Harga (Rp)',
                            hintText: 'Contoh: 2500000',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Harga wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // Jumlah
                        TextFormField(
                          controller: _jumlahC,
                          decoration: InputDecoration(
                            labelText: 'Jumlah',
                            hintText: 'Contoh: 5',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Jumlah wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // Tanggal Masuk
                        TextFormField(
                          controller: _tanggalC,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Tanggal Masuk (yyyy-MM-dd)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.date_range),
                              onPressed: _pickDate,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                87,
                                86,
                                86,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: Text(isEdit ? 'SIMPAN PERUBAHAN' : 'SIMPAN'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
