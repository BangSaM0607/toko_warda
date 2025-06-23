// barang_form_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final TextEditingController _satuanController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();

  String _kategori = 'Sembako';

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      _namaController.text = widget.data['nama_barang'];
      _kategori = widget.data['kategori'];
      _stokController.text = widget.data['stok'].toString();
      _hargaController.text = widget.data['harga'].toString();
      _satuanController.text = widget.data['satuan'];
      _deskripsiController.text = widget.data['deskripsi'] ?? '';
      _barcodeController.text = widget.data['barcode'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
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
          DropdownButtonFormField<String>(
            value: _kategori,
            items:
                [
                  'Sembako',
                  'Minuman',
                  'Snack',
                  'Alat Dapur',
                  'Kebutuhan Rumah',
                  'Perawatan Tubuh',
                ].map((kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _kategori = value!;
              });
            },
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
          const SizedBox(height: 10),
          TextField(
            controller: _satuanController,
            decoration: const InputDecoration(labelText: 'Satuan'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _deskripsiController,
            decoration: const InputDecoration(labelText: 'Deskripsi'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _barcodeController,
            decoration: const InputDecoration(labelText: 'Barcode'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_namaController.text.isEmpty ||
                  _stokController.text.isEmpty ||
                  _hargaController.text.isEmpty) {
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
                'kategori': _kategori,
                'stok': int.tryParse(_stokController.text) ?? 0,
                'satuan': _satuanController.text,
                'harga': int.tryParse(_hargaController.text) ?? 0,
                'deskripsi': _deskripsiController.text,
                'barcode': _barcodeController.text,
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
                  const SnackBar(
                    content: Text('Gagal menyimpan data'),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 200),
                    duration: Duration(seconds: 2),
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
