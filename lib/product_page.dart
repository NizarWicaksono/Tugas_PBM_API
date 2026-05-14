import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'models/product_models.dart'; 
import 'add_product.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final _storage = const FlutterSecureStorage();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Panggil data produk segera setelah halaman dibuka
    _fetchProducts();
  }

  // Fungsi untuk mengambil data produk dari server
  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    
    try {
      // 1. Ambil token dari storage
      String? token = await _storage.read(key: 'token');
      if (token == null) throw Exception('Token tidak ditemukan');

      // 2. Request GET ke endpoint produk dengan membawa Bearer Token
      final response = await http.get(
        Uri.parse('https://task.itprojects.web.id/api/products'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      // 3. Jika berhasil (status 200), ubah JSON menjadi List of Product
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> productList = data['products']; 
        
        setState(() {
          _products = productList.map((json) => Product.fromJson(json)).toList();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengambil data produk')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan jaringan')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          // Tombol untuk Submit Tugas (Nanti kita fungsikan)
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Submit Tugas',
            onPressed: () {
              // TODO: Buat fitur submit tugas
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Animasi loading
          : _products.isEmpty
              ? const Center(child: Text('Belum ada draft produk. Silakan tambah!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Rp ${product.price}',
                              style: const TextStyle(
                                color: Colors.green, 
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(product.description),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      // Tombol Tambah Produk
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
            final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProductPage()),
              );
              if (result == true) {
                _fetchProducts(); // Refresh data produk setelah kembali dari halaman tambah
              }
        },
      ),
    );
  }
}