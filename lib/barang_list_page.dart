import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'barang_form_page.dart';

class BarangListPage extends StatefulWidget {
  const BarangListPage({super.key});

  @override
  State<BarangListPage> createState() => _BarangListPageState();
}

class _BarangListPageState extends State<BarangListPage> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchBarang() async {
    final response = await supabase.from('toko_warda').select();
    return List<Map<String, dynamic>>.from(response);
  }

  void deleteBarang(String id) async {
    await supabase.from('toko_warda').delete().eq('id', id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Barang Toko Warda')),
      body: FutureBuilder(
        future: fetchBarang(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final barang = snapshot.data!;
          return ListView.builder(
            itemCount: barang.length,
            itemBuilder: (context, index) {
              final item = barang[index];
              return ListTile(
                title: Text(item['nama_barang']),
                subtitle: Text(
                  'Kategori: ${item['kategori']} | Stok: ${item['stok']} | Harga: ${item['harga']}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BarangFormPage(data: item),
                          ),
                        );
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteBarang(item['id']),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BarangFormPage()),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
