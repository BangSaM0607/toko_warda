import 'package:flutter/material.dart'; // import material flutter
import 'package:supabase_flutter/supabase_flutter.dart'; // import supabase_flutter
import 'pages/barang_list_page.dart'; // import barang_list_page.dart

Future<void> main() async {
  await Supabase.initialize(
    url:
        'https://lleiuchgukmblykhhduz.supabase.co', // ganti dengan URL Supabase Anda
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxsZWl1Y2hndWttYmx5a2hoZHV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2MjU1MzYsImV4cCI6MjA2MzIwMTUzNn0.TolJDNpew7JVGe2tP9ngx3BHR97LNNvyZNTALE-cDT8',
  ); // ganti dengan Anon Key Supabase Anda

  runApp(MyApp()); // jalankan aplikasi
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Warda', // judul aplikasi
      theme: ThemeData(primarySwatch: Colors.green), // tema aplikasi
      debugShowCheckedModeBanner: false, // ✅ ini untuk hilangkan DEBUG
      home: const BarangListPage(), // halaman utama aplikasi
    );
  }
}
