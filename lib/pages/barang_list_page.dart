import 'package:flutter/material.dart'; // Import package Flutter Material UI
import 'package:supabase_flutter/supabase_flutter.dart'; // Import package Supabase Flutter
import 'barang_form_page.dart'; // Import halaman form tambah/edit barang
import 'login_page.dart'; // Import halaman login (untuk logout)
import '../main.dart'; // Import role user global dari main.dart

class BarangListPage extends StatefulWidget {
  const BarangListPage({super.key}); // Constructor

  @override
  State<BarangListPage> createState() => _BarangListPageState(); // Buat state page
}

class _BarangListPageState extends State<BarangListPage> {
  List<dynamic> barangList = []; // List barang (dari Supabase)
  bool isLoading = false; // Status loading
  String searchQuery = ''; // String pencarian
  String selectedKategori = 'Semua'; // Filter kategori (dropdown)

  final kategoriList = [
    'Semua',
    'Sembako',
    'Minuman',
    'Snack',
    'Kesehatan',
    'Kecantikan',
    'Lainnya',
  ]; // List kategori

  bool isAdmin() {
    return currentUserRole == 'admin'; // Cek role admin
  }

  bool isKasir() {
    return currentUserRole == 'kasir'; // Cek role kasir
  }

  @override
  void initState() {
    super.initState(); // Panggil init bawaan
    loadBarang(); // Load barang saat page tampil
  }

  Future<void> loadBarang() async {
    setState(() {
      isLoading = true; // Tampilkan loading
    });

    try {
      final data = await Supabase.instance.client
          .from('toko_warda')
          .select()
          .order('id', ascending: false); // Query barang

      setState(() {
        barangList = data; // Simpan ke list
      });
    } catch (e) {
      showSnackbar('Gagal load data: $e'); // Tampilkan error
    } finally {
      setState(() {
        isLoading = false; // Selesai loading
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
                onPressed: () => Navigator.pop(context, false), // Batal
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true), // Hapus
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirm != true) return; // Kalau batal → keluar

    try {
      await Supabase.instance.client
          .from('toko_warda')
          .delete()
          .eq('id', id); // Hapus di Supabase
      showSnackbar('Barang berhasil dihapus'); // Tampilkan pesan
      loadBarang(); // Reload list
    } catch (e) {
      showSnackbar('Gagal hapus: $e'); // Error
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), // Isi pesan
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 200),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void logout() async {
    await Supabase.instance.client.auth.signOut(); // Logout Supabase
    currentUserRole = ''; // Reset role global
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ), // Kembali ke login
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList =
        barangList.where((barang) {
          final nama =
              (barang['nama_barang'] ?? '')
                  .toString()
                  .toLowerCase(); // Nama barang
          final kategori =
              (barang['kategori'] ?? '')
                  .toString()
                  .toLowerCase(); // Kategori barang

          final matchesSearch = nama.contains(
            searchQuery.toLowerCase(),
          ); // Filter search
          final matchesKategori =
              selectedKategori == 'Semua' ||
              kategori == selectedKategori.toLowerCase(); // Filter kategori

          return matchesSearch && matchesKategori; // Return barang yang cocok
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Barang'), // Judul
        automaticallyImplyLeading: false, // Hilangkan tombol back
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ), // Tombol logout
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
                  searchQuery = value; // Update search query
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: selectedKategori, // Kategori terpilih
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
                  selectedKategori = value!; // Update kategori
                });
              },
              decoration: const InputDecoration(labelText: 'Filter Kategori'),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(),
                    ) // Loading spinner
                    : ListView.builder(
                      itemCount:
                          filteredList.length, // Jumlah item pada ListView
                      itemBuilder: (context, index) {
                        final barang =
                            filteredList[index]; // Ambil data barang per index
                        final stok =
                            barang['stok'] ??
                            0; // Ambil stok barang, default 0 jika null
                        final harga =
                            barang['harga'] ??
                            0; // Ambil harga barang, default 0 jika null

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ), // Margin kartu
                          child: ListTile(
                            title: Text(
                              barang['nama_barang'] ??
                                  '', // Tampilkan nama barang
                            ),
                            subtitle: Text(
                              'Kategori: ${barang['kategori']} • Stok: $stok • Harga: $harga', // Info kategori, stok, harga
                            ),
                            trailing: // Tombol aksi di sebelah kanan
                                isAdmin() ||
                                        isKasir() // Jika user admin atau kasir
                                    ? Row(
                                      mainAxisSize:
                                          MainAxisSize
                                              .min, // Row sekecil mungkin
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ), // Icon edit
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => BarangFormPage(
                                                      barang:
                                                          barang, // Kirim data barang untuk edit
                                                    ),
                                              ),
                                            ).then(
                                              (_) =>
                                                  loadBarang(), // Setelah kembali, reload data barang
                                            );
                                          },
                                        ),
                                        if (isAdmin()) // Hanya admin yang bisa hapus
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ), // Icon hapus
                                            onPressed: () {
                                              final id =
                                                  barang['id']; // Ambil id barang
                                              if (id is int) {
                                                deleteBarang(
                                                  id,
                                                ); // Hapus barang
                                              } else {
                                                showSnackbar(
                                                  'Error: ID barang bukan integer', // Error jika id bukan int
                                                );
                                              }
                                            },
                                          ),
                                      ],
                                    )
                                    : null, // Jika bukan admin/kasir, tidak ada tombol aksi
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
                    MaterialPageRoute(
                      builder: (_) => const BarangFormPage(),
                    ), // Tambah barang
                  ).then((_) => loadBarang()); // Reload
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah'), // Label button
              )
              : null, // Viewer tidak bisa tambah
    );
  }
}
