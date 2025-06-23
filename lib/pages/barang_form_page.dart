// Import package Flutter
import 'package:flutter/material.dart';
// Import package Supabase
import 'package:supabase_flutter/supabase_flutter.dart';

// Definisi class BarangFormPage (halaman form tambah/edit barang)
class BarangFormPage extends StatefulWidget {
  final dynamic barang; // Data barang (jika null → mode tambah)
  const BarangFormPage({super.key, this.barang});

  @override
  State<BarangFormPage> createState() => _BarangFormPageState();
}

class _BarangFormPageState extends State<BarangFormPage> {
  // Key untuk validasi form
  final formKey = GlobalKey<FormState>();

  // Controller untuk tiap field input
  final namaController = TextEditingController();
  final kategoriController = TextEditingController();
  final stokController = TextEditingController();
  final satuanController = TextEditingController();
  final hargaController = TextEditingController();
  final deskripsiController = TextEditingController();
  final barcodeController = TextEditingController();

  // State apakah sedang proses simpan
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    // Jika mode edit → isi field dengan data barang
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

  // Fungsi untuk simpan data barang ke Supabase
  Future<void> saveBarang() async {
    // Validasi form → jika tidak valid tampil Snackbar
    if (!formKey.currentState!.validate()) {
      showSnackbar('Form kosong / gagal');
      return;
    }

    // Set state saving true
    setState(() {
      isSaving = true;
    });

    // Buat data payload untuk insert/update
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
        // Mode tambah barang baru
        await Supabase.instance.client.from('toko_warda').insert(payload);
        showSnackbar('Tambah Barang berhasil');
      } else {
        // Mode edit barang
        await Supabase.instance.client
            .from('toko_warda')
            .update(payload)
            .eq('id', widget.barang['id']);
        showSnackbar('Edit Barang berhasil');
      }

      // Kembali ke halaman sebelumnya
      Navigator.pop(context);
    } catch (e) {
      // Tampilkan error jika gagal
      showSnackbar('Gagal simpan: $e');
    } finally {
      // Reset state saving
      setState(() {
        isSaving = false;
      });
    }
  }

  // Fungsi menampilkan Snackbar (feedback ke user)
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

  // UI tampilan form
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.barang == null ? 'Tambah Barang' : 'Edit Barang',
        ), // Judul AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey, // Hubungkan formKey
          child: Column(
            children: [
              // Input nama barang
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Barang'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Input kategori
              TextFormField(
                controller: kategoriController,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Input stok (angka)
              TextFormField(
                controller: stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Input satuan
              TextFormField(
                controller: satuanController,
                decoration: const InputDecoration(labelText: 'Satuan'),
              ),
              const SizedBox(height: 12),

              // Input harga (angka)
              TextFormField(
                controller: hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Input deskripsi
              TextFormField(
                controller: deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              const SizedBox(height: 12),

              // Input barcode
              TextFormField(
                controller: barcodeController,
                decoration: const InputDecoration(labelText: 'Barcode'),
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isSaving ? null : saveBarang, // Nonaktif saat saving
                  child:
                      isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Simpan'), // Teks tombol
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
