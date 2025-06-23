import 'package:flutter/material.dart'; // Import UI Material
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'login_page.dart'; // Import LoginPage (buat pindah balik setelah register)

class RegisterPage extends StatefulWidget {
  // Widget halaman register
  const RegisterPage({super.key}); // Constructor

  @override
  State<RegisterPage> createState() => _RegisterPageState(); // Buat state
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController(); // Controller input email
  final passwordController =
      TextEditingController(); // Controller input password
  String selectedRole = 'viewer'; // Default role = viewer

  bool isLoading = false; // Status loading

  Future<void> register() async {
    // Fungsi untuk proses register
    setState(() {
      isLoading = true; // Munculkan loading saat proses
    });

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: emailController.text, // Kirim email ke Supabase Auth
        password: passwordController.text, // Kirim password
      ); // Register user di Supabase Auth

      if (res.user != null) {
        // Kalau berhasil, insert data ke tabel user_toko
        await Supabase.instance.client.from('user_toko').insert({
          'email': emailController.text, // Simpan email
          'role': selectedRole, // Simpan role (admin/kasir/viewer)
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Register berhasil. Silakan login.',
            ), // Tampilkan info sukses
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 50, vertical: 200),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ), // Pindah ke halaman Login
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal register'), // Tampilkan gagal
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 50, vertical: 200),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'), // Tampilkan error lain
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 200),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Selesai loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Background warna abu
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24), // Padding 24
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Tengah layar
            children: [
              const Icon(
                Icons.person_add,
                size: 100,
                color: Colors.green,
              ), // Icon atas
              const SizedBox(height: 20), // Spasi
              const Text(
                'Daftar Akun', // Judul
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10), // Spasi
              const Text(
                'Silakan isi data akun baru', // Subjudul
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30), // Spasi
              // EMAIL
              TextField(
                controller: emailController, // Input email
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Border bulat
                  ),
                  prefixIcon: const Icon(Icons.email_outlined), // Icon email
                ),
              ),
              const SizedBox(height: 20), // Spasi
              // PASSWORD
              TextField(
                controller: passwordController, // Input password
                obscureText: true, // Disembunyikan
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline), // Icon lock
                ),
              ),
              const SizedBox(height: 20), // Spasi
              // ROLE DROPDOWN
              DropdownButtonFormField<String>(
                value: selectedRole, // Nilai terpilih (default viewer)
                items: const [
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Admin'),
                  ), // Pilihan Admin
                  DropdownMenuItem(
                    value: 'kasir',
                    child: Text('Kasir'),
                  ), // Pilihan Kasir
                  DropdownMenuItem(
                    value: 'viewer',
                    child: Text('Viewer'),
                  ), // Pilihan Viewer
                ],
                decoration: InputDecoration(
                  labelText: 'Pilih Role',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!; // Ubah selectedRole
                  });
                },
              ),

              const SizedBox(height: 30), // Spasi
              // BUTTON REGISTER
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : register, // Tombol daftar
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.green,
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(
                            color: Colors.white,
                          ) // Loading spinner
                          : const Text(
                            'Daftar Akun', // Teks tombol
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),

              const SizedBox(height: 16), // Spasi
              // LINK KE LOGIN
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ), // Balik ke Login
                  );
                },
                child: const Text(
                  'Sudah punya akun? Login',
                ), // Teks link ke login
              ),
            ],
          ),
        ),
      ),
    );
  }
}
