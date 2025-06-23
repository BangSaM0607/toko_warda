import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BarangFormPage extends StatefulWidget {
  final dynamic barang;
  const BarangFormPage({super.key, this.barang});

  @override
  State<BarangFormPage> createState() => _BarangFormPageState();
}

class _BarangFormPageState extends State<BarangFormPage> {
  final formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final kategoriController = TextEditingController();
  final stokController = TextEditingController();
  final satuanController = TextEditingController();
  final hargaController = TextEditingController();
  final deskripsiController = TextEditingController();
  final barcodeController = TextEditingController();

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.barang != null) {
      namaController.text = widget.barang['nama_barang'] ?? '';
      kategoriController.text = widget.barang['kategori'] ?? '';
      stokController.text = widget.barang['stok']?.toString() ?? '';
      satuanController.text = widget.barang['satuan'] ?? '';
      hargaController.text = widget.barang['harga']?.toString() ?? '';
      deskripsiController.text = widget.barang['deskripsi'] ?? '';
      barcodeController.text = widget.barang['barcode'] ?? '';
    }
  }

  Future<void> saveBarang() async {
    if (!formKey.currentState!.validate()) {
      showSnackbar('Form kosong / gagal');
      return;
    }

    setState(() {
      isSaving = true;
    });

    final payload = {
      'nama_barang': namaController.text.trim(),
      'kategori': kategoriController.text.trim(),
      'stok': int.tryParse(stokController.text.trim()) ?? 0,
      'satuan': satuanController.text.trim(),
      'harga': int.tryParse(hargaController.text.trim()) ?? 0,
      'deskripsi': deskripsiController.text.trim(),
      'barcode': barcodeController.text.trim(),
    };

    try {
      if (widget.barang == null) {
        await Supabase.instance.client.from('toko_warda').insert(payload);
        showSnackbar('Tambah Barang berhasil');
      } else {
        await Supabase.instance.client
            .from('toko_warda')
            .update(payload)
            .eq('id', widget.barang['id']);
        showSnackbar('Edit Barang berhasil');
      }

      Navigator.pop(context);
    } catch (e) {
      showSnackbar('Gagal simpan: $e');
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 200),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.barang == null ? 'Tambah Barang' : 'Edit Barang'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Barang'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: kategoriController,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: satuanController,
                decoration: const InputDecoration(labelText: 'Satuan'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: barcodeController,
                decoration: const InputDecoration(labelText: 'Barcode'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : saveBarang,
                  child:
                      isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
