import 'package:flutter/material.dart';
import 'login.dart'; // Import file yang baru dibuat

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tugas PBM 2026',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(), // Tampilkan halaman login sebagai home
    );
  }
}