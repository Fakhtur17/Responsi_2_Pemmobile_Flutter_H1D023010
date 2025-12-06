import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/app_user.dart';
import '../models/inventory.dart';

class ApiService {
  // Ubah jika perlu (misal pakai 10.0.2.2)
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // ---------- AUTH ----------

  Future<void> register(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200 || data['status'] != true) {
      throw Exception(data['message'] ?? 'Registrasi gagal');
    }
  }

  Future<AppUser> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200 || data['status'] != true) {
      throw Exception(data['message'] ?? 'Login gagal');
    }

    return AppUser.fromLoginJson(data);
  }

  // ---------- INVENTORY CRUD (BUTUH TOKEN) ----------

  Map<String, String> _headersWithToken(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Inventory>> getInventories(String token) async {
    final url = Uri.parse('$baseUrl/inventories');
    final response = await http.get(url, headers: _headersWithToken(token));

    final data = jsonDecode(response.body);
    if (response.statusCode != 200 || data['status'] != true) {
      throw Exception(data['message'] ?? 'Gagal mengambil data');
    }

    final List list = data['data'] ?? [];
    return list.map((e) => Inventory.fromJson(e)).toList();
  }

  Future<Inventory> createInventory(String token, Inventory inv) async {
    final url = Uri.parse('$baseUrl/inventories');
    final response = await http.post(
      url,
      headers: _headersWithToken(token),
      body: jsonEncode(inv.toJson()),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menambah data');
    }

    return Inventory.fromJson(data['data']);
  }

  Future<void> updateInventory(String token, Inventory inv) async {
    final url = Uri.parse('$baseUrl/inventories/${inv.id}');
    final response = await http.put(
      url,
      headers: _headersWithToken(token),
      body: jsonEncode(inv.toJson()),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200 || data['status'] != true) {
      throw Exception(data['message'] ?? 'Gagal mengubah data');
    }
  }

  Future<void> deleteInventory(String token, int id) async {
    final url = Uri.parse('$baseUrl/inventories/$id');
    final response = await http.delete(url, headers: _headersWithToken(token));

    if (response.statusCode != 200 && response.statusCode != 204) {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Gagal menghapus data');
      } catch (_) {
        throw Exception('Gagal menghapus data');
      }
    }
  }
}
