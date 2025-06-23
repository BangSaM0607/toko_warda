import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'barang_list_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError('Email & Password wajib diisi');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userId = response.user?.id;
      if (userId == null) {
        showError('Login gagal');
        return;
      }

      final data =
          await Supabase.instance.client
              .from('user_toko')
              .select()
              .eq('email', email)
              .maybeSingle();

      if (data != null) {
        currentUserRole = (data['role'] ?? '').trim().toLowerCase();
      } else {
        currentUserRole = 'viewer';
      }

      print('ROLE LOGIN: $currentUserRole');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BarangListPage()),
      );
    } catch (e) {
      showError('Login gagal: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Login Toko Warda', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text('Daftar akun baru'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
