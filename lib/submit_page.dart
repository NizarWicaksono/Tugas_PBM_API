import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SubmitPage extends StatefulWidget {
  const SubmitPage({super.key});

  @override
  State<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;

  Future<void> _submitTugas() async {
    if (_nameController.text.isEmpty || _descController.text.isEmpty || _githubController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom wajib diisi!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? token = await _storage.read(key: 'token');
      
      final response = await http.post(
        Uri.parse('https://task.itprojects.web.id/api/products/submit'), // Endpoint khusus Submit
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'description': _descController.text,
          'github_url': _githubController.text, // Link GitHub
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 Tugas Berhasil Disubmit!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context); // Kembali ke katalog setelah sukses
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal Submit: ${response.body}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kumpulkan Tugas'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Pastikan repository GitHub kamu bersifat PUBLIC!',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Produk Final', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Pesan / Deskripsi', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _githubController,
              decoration: const InputDecoration(
                labelText: 'Link GitHub Repository',
                hintText: 'https://github.com/NizarWicaksono/...',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                onPressed: _isLoading ? null : _submitTugas,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Kumpulkan Tugas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}