import 'package:flutter/material.dart'; // Import UI material
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase Flutter
import '../main.dart'; // Import main.dart (untuk currentUserRole)
import 'barang_list_page.dart'; // Import page BarangListPage (setelah login)
import 'register_page.dart'; // Import page RegisterPage (untuk daftar akun)

class LoginPage extends StatefulWidget {
  // Widget halaman login
  const LoginPage({super.key}); // Constructor

  @override
  State<LoginPage> createState() => _LoginPageState(); // Buat state page
}

class _LoginPageState extends State<LoginPage> {
  // State untuk LoginPage
  final emailController = TextEditingController(); // Controller input email
  final passwordController =
      TextEditingController(); // Controller input password
  bool isLoading = false; // Status loading

  Future<void> login() async {
    // Fungsi login
    final email = emailController.text.trim(); // Ambil email
    final password = passwordController.text.trim(); // Ambil password

    if (email.isEmpty || password.isEmpty) {
      // Validasi input kosong
      showError('Email & Password wajib diisi');
      return;
    }

    setState(() {
      isLoading = true; // Tampilkan loading
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      ); // Login ke Supabase Auth

      final userId = response.user?.id; // Ambil user ID
      if (userId == null) {
        showError('Login gagal'); // Gagal login
        return;
      }

      final data =
          await Supabase.instance.client
              .from('user_toko')
              .select()
              .eq('email', email)
              .maybeSingle(); // Ambil role dari table user_toko

      if (data != null) {
        currentUserRole =
            (data['role'] ?? '').trim().toLowerCase(); // Set role global
      } else {
        currentUserRole = 'viewer'; // Default viewer
      }

      print('ROLE LOGIN: $currentUserRole'); // Debug role

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BarangListPage(),
        ), // Pindah ke page BarangListPage
      );
    } catch (e) {
      showError('Login gagal: $e'); // Tampilkan error login
    } finally {
      setState(() {
        isLoading = false; // Selesai loading
      });
    }
  }

  void showError(String message) {
    // Fungsi menampilkan error snackbar
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // Build UI halaman login
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24), // Padding 24
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Login Toko Warda',
                style: TextStyle(fontSize: 24),
              ), // Judul
              const SizedBox(height: 24), // Spasi
              TextField(
                controller: emailController, // Input email
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12), // Spasi
              TextField(
                controller: passwordController, // Input password
                obscureText: true, // Password disembunyikan
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 24), // Spasi
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login, // Tombol login
                  child:
                      isLoading
                          ? const CircularProgressIndicator(
                            color: Colors.white,
                          ) // Loading spinner
                          : const Text('Login'), // Teks Login
                ),
              ),
              const SizedBox(height: 16), // Spasi
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterPage(),
                    ), // Pindah ke page register
                  );
                },
                child: const Text('Daftar akun baru'), // Teks daftar
              ),
            ],
          ),
        ),
      ),
    );
  }
}
