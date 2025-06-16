import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BarangFormPage extends StatefulWidget {
  final Map<String, dynamic>? data;

  const BarangFormPage({super.key, this.data});

  @override
  State<BarangFormPage> createState() => _BarangFormPageState();
}

class _BarangFormPageState extends State<BarangFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController kategoriController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController stokController = TextEditingController();

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      namaController.text = widget.data!['nama_barang'];
      kategoriController.text = widget.data!['kategori'];
      hargaController.text = widget.data!['harga'].toString();
      stokController.text = widget.data!['stok'].toString();
    }
  }

  Future<void> saveData() async {
    final data = {
      'nama_barang': namaController.text,
      'kategori': kategoriController.text,
      'harga': double.parse(hargaController.text),
      'stok': int.parse(stokController.text),
    };

    if (widget.data == null) {
      await supabase.from('toko_warda').insert(data);
    } else {
      await supabase
          .from('toko_warda')
          .update(data)
          .eq('id', widget.data!['id']);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data == null ? 'Tambah Barang' : 'Edit Barang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Barang'),
                validator:
                    (value) => value!.isEmpty ? 'Tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: kategoriController,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator:
                    (value) => value!.isEmpty ? 'Tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? 'Tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? 'Tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveData();
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
