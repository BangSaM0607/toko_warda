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

  String keyword = '';
  String selectedKategori = 'Semua';
  List<String> kategoriList = [
    'Semua',
    'Sembako',
    'Minuman',
    'Snack',
    'Alat Dapur',
    'Kebutuhan Rumah',
    'Perawatan Tubuh',
  ];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBarang();
  }

  Future<void> fetchBarang() async {
    final data = await supabase.from('toko_warda').select().order('id');
    final filtered =
        data.where((item) {
          final nama = item['nama_barang'].toString().toLowerCase();
          final kategori = item['kategori'].toString().toLowerCase();
          final matchNama = nama.contains(keyword.toLowerCase());
          final matchKategori =
              selectedKategori == 'Semua' ||
              kategori == selectedKategori.toLowerCase();
          return matchNama && matchKategori;
        }).toList();

    setState(() {
      barangList = filtered;
    });
  }

  Future<void> deleteBarang(String id) async {
    try {
      await supabase.from('toko_warda').delete().eq('id', id);
      fetchBarang();
    } catch (e) {
      print('Gagal hapus: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Barang Toko WARDA'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchBarang),
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
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama barang...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        keyword = '';
                        fetchBarang();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    keyword = value;
                    fetchBarang();
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Kategori:'),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedKategori,
                        items:
                            kategoriList.map((kategori) {
                              return DropdownMenuItem(
                                value: kategori,
                                child: Text(kategori),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedKategori = value!;
                          });
                          fetchBarang();
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child:
                barangList.isEmpty
                    ? const Center(child: Text('Data tidak ditemukan'))
                    : ListView.builder(
                      itemCount: barangList.length,
                      itemBuilder: (context, index) {
                        final item = barangList[index];
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
                                Text(
                                  'Stok: ${item['stok']} ${item['satuan']}',
                                  style: TextStyle(
                                    color:
                                        item['stok'] <= 5
                                            ? Colors.red
                                            : Colors.black,
                                    fontWeight:
                                        item['stok'] <= 5
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
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
                                    await deleteBarang(item['id'].toString());
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
