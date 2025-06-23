// register_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String selectedRole = 'viewer'; // default role

  bool isLoading = false;

  Future<void> register() async {
    setState(() {
      isLoading = true;
    });

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
      );

      if (res.user != null) {
        // Insert ke user_toko
        await Supabase.instance.client.from('user_toko').insert({
          'email': emailController.text,
          'role': selectedRole,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Register berhasil. Silakan login.'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 50, vertical: 200),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal register'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 50, vertical: 200),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 200),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add, size: 100, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                'Daftar Akun',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Silakan isi data akun baru',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              // EMAIL
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 20),

              // PASSWORD
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 20),

              // ROLE DROPDOWN
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'kasir', child: Text('Kasir')),
                  DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                ],
                decoration: InputDecoration(
                  labelText: 'Pilih Role',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
              ),

              const SizedBox(height: 30),

              // BUTTON REGISTER
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.green,
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Daftar Akun',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),

              const SizedBox(height: 16),

              // LINK KE LOGIN
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text('Sudah punya akun? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
