// barang_form_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart'; // untuk currentUserRole

class BarangFormPage extends StatefulWidget {
  final dynamic data;
  const BarangFormPage({super.key, this.data});

  @override
  State<BarangFormPage> createState() => _BarangFormPageState();
}

class _BarangFormPageState extends State<BarangFormPage> {
  final supabase = Supabase.instance.client;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      _namaController.text = widget.data['nama_barang'];
      _stokController.text = widget.data['stok'].toString();
      _hargaController.text = widget.data['harga'].toString();
      _kategoriController.text = widget.data['kategori'];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserRole == 'viewer') {
      return const Scaffold(body: Center(child: Text('Akses ditolak')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data == null ? 'Tambah Barang' : 'Edit Barang'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _namaController,
            decoration: const InputDecoration(labelText: 'Nama Barang'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _kategoriController,
            decoration: const InputDecoration(labelText: 'Kategori'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _stokController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Stok'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _hargaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Harga'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_namaController.text.isEmpty ||
                  _stokController.text.isEmpty ||
                  _hargaController.text.isEmpty ||
                  _kategoriController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mohon lengkapi semua data'),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 200),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              final data = {
                'nama_barang': _namaController.text,
                'kategori': _kategoriController.text,
                'stok': int.tryParse(_stokController.text) ?? 0,
                'harga': int.tryParse(_hargaController.text) ?? 0,
              };

              try {
                if (widget.data == null) {
                  await supabase.from('toko_warda').insert(data);
                } else {
                  await supabase
                      .from('toko_warda')
                      .update(data)
                      .eq('id', widget.data['id']);
                }

                Navigator.pop(context, 'saved');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menyimpan: $e'),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 200,
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
