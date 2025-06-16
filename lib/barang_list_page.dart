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
  List<dynamic> barangList = [];

  @override
  void initState() {
    super.initState();
    fetchBarang();
  }

  Future<void> fetchBarang() async {
    final response = await supabase
        .from('toko_warda')
        .select()
        .order('id', ascending: true);
    setState(() => barangList = response);
  }

  Future<void> deleteBarang(int id) async {
    await supabase.from('toko_warda').delete().eq('id', id);
    fetchBarang();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Barang Toko WARDA')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BarangFormPage()),
          );
          fetchBarang();
        },
        child: const Icon(Icons.add),
      ),
      body:
          barangList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: barangList.length,
                itemBuilder: (context, index) {
                  final item = barangList[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(item['nama_barang']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kategori: ${item['kategori']}'),
                          Text(
                            'Harga: Rp ${item['harga']} / ${item['satuan']}',
                          ),
                          Text('Stok: ${item['stok']} ${item['satuan']}'),
                        ],
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
                              fetchBarang();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await deleteBarang(item['id']);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
