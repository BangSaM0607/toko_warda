import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BarangFormPage extends StatefulWidget {
  final Map<String, dynamic>? data;
  const BarangFormPage({super.key, this.data});

  @override
  State<BarangFormPage> createState() => _BarangFormPageState();
}

class _BarangFormPageState extends State<BarangFormPage> {
  final supabase = Supabase.instance.client;

  final TextEditingController namaController = TextEditingController();
  final TextEditingController kategoriController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController stokController = TextEditingController();
  final TextEditingController satuanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      namaController.text = widget.data!['nama_barang'] ?? '';
      kategoriController.text = widget.data!['kategori'] ?? '';
      hargaController.text = widget.data!['harga'].toString();
      stokController.text = widget.data!['stok'].toString();
      satuanController.text = widget.data!['satuan'] ?? '';
    }
  }

  Future<void> simpanBarang() async {
    final data = {
      'nama_barang': namaController.text,
      'kategori': kategoriController.text,
      'harga': int.tryParse(hargaController.text) ?? 0,
      'stok': int.tryParse(stokController.text) ?? 0,
      'satuan': satuanController.text,
    };

    if (widget.data == null) {
      await supabase.from('toko_warda').insert(data);
    } else {
      await supabase
          .from('toko_warda')
          .update(data)
          .eq('id', widget.data!['id']);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data == null ? 'Tambah Barang' : 'Edit Barang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Barang'),
            ),
            TextField(
              controller: kategoriController,
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
            TextField(
              controller: hargaController,
              decoration: const InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: stokController,
              decoration: const InputDecoration(labelText: 'Stok'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: satuanController,
              decoration: const InputDecoration(labelText: 'Satuan'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: simpanBarang,
              child: Text(widget.data == null ? 'Simpan' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
