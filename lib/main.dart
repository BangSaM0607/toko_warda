// Import package Flutter material (komponen UI bawaan Flutter)
import 'package:flutter/material.dart';

// Import package Supabase (untuk koneksi ke Supabase)
import 'package:supabase_flutter/supabase_flutter.dart';

// Import halaman login (custom page buatan kita)
import 'pages/login_page.dart';

// Fungsi utama aplikasi (main)
Future<void> main() async {
  // Pastikan binding Flutter sudah siap (untuk async & inisialisasi Supabase)
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url:
        'https://lleiuchgukmblykhhduz.supabase.co', // URL Supabase Project (endpoint)
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxsZWl1Y2hndWttYmx5a2hoZHV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2MjU1MzYsImV4cCI6MjA2MzIwMTUzNn0.TolJDNpew7JVGe2tP9ngx3BHR97LNNvyZNTALE-cDT8', // anonKey Supabase API (public)
  );

  // Jalankan aplikasi Flutter (root widget = MyApp)
  runApp(const MyApp());
}

// Variabel global untuk menyimpan role user yang sedang login
// Contoh isi: 'admin', 'kasir', 'viewer'
String currentUserRole = '';

// Class utama aplikasi (root widget)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Warda', // Judul aplikasi di tab / task manager
      debugShowCheckedModeBanner:
          false, // Hilangkan banner debug pojok kanan atas
      theme: ThemeData(
        primarySwatch: Colors.green, // Tema warna dominan aplikasi
      ),
      home: const LoginPage(), // Halaman pertama yang muncul = LoginPage
    );
  }
}
