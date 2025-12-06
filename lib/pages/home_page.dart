import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../models/inventory.dart';
import '../services/api_service.dart';
import 'inventory_form_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final AppUser user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _api = ApiService();
  bool _loading = true;
  List<Inventory> _items = [];

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final data = await _api.getInventories(widget.user.token);
      setState(() {
        _items = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addItem() async {
    final result = await Navigator.push<Inventory?>(
      context,
      MaterialPageRoute(builder: (_) => const InventoryFormPage()),
    );
    if (result != null) {
      try {
        await _api.createInventory(widget.user.token, result);
        await _loadData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _editItem(Inventory item) async {
    final result = await Navigator.push<Inventory?>(
      context,
      MaterialPageRoute(builder: (_) => InventoryFormPage(inventory: item)),
    );
    if (result != null) {
      try {
        final updated = Inventory(
          id: item.id,
          nama: result.nama,
          harga: result.harga,
          jumlah: result.jumlah,
          tanggalMasuk: result.tanggalMasuk,
        );
        await _api.updateInventory(widget.user.token, updated);
        await _loadData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _deleteItem(Inventory item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Yakin ingin menghapus "${item.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('HAPUS'),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await _api.deleteInventory(widget.user.token, item.id);
        await _loadData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background agak gelap biar modern
      backgroundColor: const Color.fromARGB(255, 120, 120, 120),
      appBar: AppBar(
        title: const Text(
          'Inventaris Komputer Ramadhan Fakhtur',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: const Color.fromARGB(255, 93, 93, 93),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 72,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada data inventaris',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tekan tombol + di kanan bawah untuk menambahkan barang baru.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: _items.length,
                  itemBuilder: (_, index) {
                    final item = _items[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _editItem(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey[800],
                              child: Text(
                                item.nama.isNotEmpty
                                    ? item.nama[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            title: Text(
                              item.nama,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Harga: Rp ${item.harga}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Jumlah: ${item.jumlah}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tanggal masuk: ${item.tanggalMasuk}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            isThreeLine: true,
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editItem(item);
                                } else if (value == 'delete') {
                                  _deleteItem(item);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 18),
                                      SizedBox(width: 8),
                                      Text('Hapus'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        backgroundColor: Colors.grey[850],
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}
