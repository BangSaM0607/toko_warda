// barang_list_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'barang_form_page.dart';
import 'login_page.dart'; // untuk ambil currentUserRole
import 'package:intl/intl.dart';

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
    final data = await supabase.from('toko_warda').select().order('id');
    setState(() {
      barangList = data;
    });
  }

  Future<void> deleteBarang(String id) async {
    try {
      await supabase.from('toko_warda').delete().eq('id', id);
      fetchBarang();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barang berhasil dihapus'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 50, vertical: 200),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal hapus: $e'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 200),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String formatRupiah(int angka) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(angka);
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
      body: Column(
        children: [
          if (currentUserRole == 'admin' || currentUserRole == 'kasir')
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tambah Barang'),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BarangFormPage()),
                  );
                  if (result == 'saved') {
                    fetchBarang();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Barang berhasil ditambahkan'),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 200,
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          Expanded(
            child:
                barangList.isEmpty
                    ? const Center(child: Text('Belum ada data barang'))
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
                                Text('Harga: ${formatRupiah(item['harga'])}'),
                                Text(
                                  'Stok: ${item['stok']}',
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
                                if (currentUserRole == 'admin' ||
                                    currentUserRole == 'kasir')
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => BarangFormPage(data: item),
                                        ),
                                      );
                                      if (result == 'saved') {
                                        fetchBarang();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Barang berhasil diperbarui',
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 50,
                                              vertical: 200,
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                if (currentUserRole == 'admin')
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: const Text(
                                                'Konfirmasi Hapus',
                                              ),
                                              content: Text(
                                                'Yakin hapus "${item['nama_barang']}"?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: const Text('Batal'),
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                  child: const Text('Hapus'),
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                ),
                                              ],
                                            ),
                                      );
                                      if (confirm == true) {
                                        await deleteBarang(
                                          item['id'].toString(),
                                        );
                                      }
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
