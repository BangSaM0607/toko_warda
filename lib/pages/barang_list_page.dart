import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'barang_form_page.dart';
import 'login_page.dart';
import '../main.dart';

class BarangListPage extends StatefulWidget {
  const BarangListPage({super.key});

  @override
  State<BarangListPage> createState() => _BarangListPageState();
}

class _BarangListPageState extends State<BarangListPage> {
  List<dynamic> barangList = [];
  bool isLoading = false;
  String searchQuery = '';
  String selectedKategori = 'Semua';

  final kategoriList = [
    'Semua',
    'Sembako',
    'Minuman',
    'Snack',
    'Kesehatan',
    'Kecantikan',
    'Lainnya',
  ];

  bool isAdmin() {
    return currentUserRole == 'admin';
  }

  bool isKasir() {
    return currentUserRole == 'kasir';
  }

  @override
  void initState() {
    super.initState();
    loadBarang();
  }

  Future<void> loadBarang() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await Supabase.instance.client
          .from('toko_warda')
          .select()
          .order('id', ascending: false);

      setState(() {
        barangList = data;
      });
    } catch (e) {
      showSnackbar('Gagal load data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteBarang(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Yakin hapus barang?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await Supabase.instance.client.from('toko_warda').delete().eq('id', id);

      showSnackbar('Barang berhasil dihapus');
      loadBarang();
    } catch (e) {
      showSnackbar('Gagal hapus: $e');
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

  void logout() async {
    await Supabase.instance.client.auth.signOut();

    currentUserRole = '';

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList =
        barangList.where((barang) {
          final nama = (barang['nama_barang'] ?? '').toString().toLowerCase();
          final kategori = (barang['kategori'] ?? '').toString().toLowerCase();

          final matchesSearch = nama.contains(searchQuery.toLowerCase());
          final matchesKategori =
              selectedKategori == 'Semua' ||
              kategori == selectedKategori.toLowerCase();

          return matchesSearch && matchesKategori;
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Barang'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Cari nama barang...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: selectedKategori,
              items:
                  kategoriList
                      .map(
                        (kategori) => DropdownMenuItem(
                          value: kategori,
                          child: Text(kategori),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedKategori = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Filter Kategori'),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final barang = filteredList[index];
                        final stok = barang['stok'] ?? 0;
                        final harga = barang['harga'] ?? 0;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text(barang['nama_barang'] ?? ''),
                            subtitle: Text(
                              'Kategori: ${barang['kategori']} • Stok: $stok • Harga: $harga',
                            ),
                            trailing:
                                isAdmin() || isKasir()
                                    ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => BarangFormPage(
                                                      barang: barang,
                                                    ),
                                              ),
                                            ).then((_) => loadBarang());
                                          },
                                        ),
                                        if (isAdmin())
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              final id = barang['id'];
                                              if (id is int) {
                                                deleteBarang(id);
                                              } else {
                                                showSnackbar(
                                                  'Error: ID barang bukan integer',
                                                );
                                              }
                                            },
                                          ),
                                      ],
                                    )
                                    : null,
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton:
          isAdmin() || isKasir()
              ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BarangFormPage()),
                  ).then((_) => loadBarang());
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah'),
              )
              : null,
    );
  }
}
