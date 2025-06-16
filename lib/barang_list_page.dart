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
  String searchQuery = '';
  String selectedKategori = 'Semua';

  Future<List<Map<String, dynamic>>> fetchBarang() async {
    var query = supabase.from('toko_warda').select();

    if (searchQuery.isNotEmpty) {
      query = query.ilike('nama_barang', '%$searchQuery%');
    }

    if (selectedKategori != 'Semua') {
      query = query.eq('kategori', selectedKategori);
    }

    final response = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<String>> fetchKategori() async {
    final response =
        await supabase
            .from('toko_warda')
            .select('kategori')
            .neq('kategori', '')
            .execute();

    final list = List<Map<String, dynamic>>.from(response.data);
    final kategoriList =
        list.map((e) => e['kategori'].toString()).toSet().toList();
    kategoriList.sort();
    kategoriList.insert(0, 'Semua');
    return kategoriList;
  }

  void deleteBarang(String id) async {
    await supabase.from('toko_warda').delete().eq('id', id);
    setState(() {});
  }

  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Barang Toko Warda'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: refresh),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Cari Barang',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          FutureBuilder(
            future: fetchKategori(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final kategoriList = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DropdownButton<String>(
                  value: selectedKategori,
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      selectedKategori = value!;
                    });
                  },
                  items:
                      kategoriList.map((kategori) {
                        return DropdownMenuItem<String>(
                          value: kategori,
                          child: Text(kategori),
                        );
                      }).toList(),
                ),
              );
            },
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchBarang(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final barang = snapshot.data!;
                if (barang.isEmpty) {
                  return const Center(child: Text('Tidak ada data'));
                }
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
          ),
        ],
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
