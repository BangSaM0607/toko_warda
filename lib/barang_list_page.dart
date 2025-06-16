import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BarangListPage extends StatefulWidget {
  const BarangListPage({Key? key}) : super(key: key);

  @override
  State<BarangListPage> createState() => _BarangListPageState();
}

class _BarangListPageState extends State<BarangListPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> barangList = [];
  bool isLoading = true;

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

    setState(() {
      barangList = response;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Barang Toko WARDA'),
        backgroundColor: Colors.green,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
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
                      title: Text('${item['nama_barang']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kategori: ${item['kategori']}'),
                          Text(
                            'Harga: Rp ${item['harga']} / ${item['satuan']}',
                          ),
                          Text('Stok: ${item['stok']} ${item['satuan']}'),
                          Text('Deskripsi: ${item['deskripsi']}'),
                          Text('Barcode: ${item['barcode']}'),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
    );
  }
}
