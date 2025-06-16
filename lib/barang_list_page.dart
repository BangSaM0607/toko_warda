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
  List<dynamic> filteredList = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBarang();
    searchController.addListener(_filterSearchResults);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchBarang() async {
    final response = await supabase
        .from('toko_warda')
        .select()
        .order('id', ascending: true);

    setState(() {
      barangList = response;
      filteredList = response;
    });
  }

  void _filterSearchResults() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => filteredList = barangList);
    } else {
      setState(() {
        filteredList =
            barangList.where((item) {
              final nama = item['nama_barang'].toString().toLowerCase();
              final kategori = item['kategori'].toString().toLowerCase();
              return nama.contains(query) || kategori.contains(query);
            }).toList();
      });
    }
  }

  Future<void> deleteBarang(int id) async {
    await supabase.from('toko_warda').delete().eq('id', id);
    fetchBarang();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Barang Toko WARDA'),
        actions: [
          IconButton(onPressed: fetchBarang, icon: const Icon(Icons.refresh)),
        ],
      ),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Cari barang atau kategori...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child:
                filteredList.isEmpty
                    ? const Center(child: Text('Data tidak ditemukan'))
                    : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
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
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => BarangFormPage(data: item),
                                      ),
                                    );
                                    fetchBarang();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
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
          ),
        ],
      ),
    );
  }
}
