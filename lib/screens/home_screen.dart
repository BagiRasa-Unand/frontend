import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../models/item.dart';
import '../routes/app_routes.dart'; // (import) untuk navigasi ke Detail
import '../widgets/state_views.dart'; // (import) LoadingView, EmptyView, ErrorView

// (1) enum status tampilan
enum ViewStatus { loading, success, error }

/// Layar Home BagiRasa – menampilkan daftar listing donasi makanan surplus.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // (2) variabel state
  final _repository = ItemRepository();
  ViewStatus _status = ViewStatus.loading;
  List<Item> _items = [];
  String _errorMessage = '';
  final bool _simulateError = false; // ubah ke true untuk menguji error state

  // (3) ambil data saat layar pertama kali dibuka
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // (4) mengambil data + menangani error
  Future<void> _loadItems() async {
    if (_status != ViewStatus.loading) {
      setState(() => _status = ViewStatus.loading);
    }
    try {
      final items = await _repository.fetchItems(simulateError: _simulateError);
      if (!mounted) return; // (4) cek mounted setelah await
      setState(() {
        _items = items;
        _status = ViewStatus.success;
      });
    } catch (e) {
      if (!mounted) return; // (4) cek mounted setelah await
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _status = ViewStatus.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6),
        title: const Text(
          'BagiRasa',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D5A3D),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildContent(), // (5) isi layar tergantung status
      ),
    );
  }

  // (6) memilih tampilan: loading / error / empty / daftar data
  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const LoadingView(),
      ViewStatus.error => ErrorView(
        message: _errorMessage,
        onRetry: _loadItems,
      ),
      ViewStatus.success => _buildList(),
    };
  }

  Widget _buildList() {
    if (_items.isEmpty) {
      return const EmptyView(
        message: 'Belum ada donasi yang tersedia saat ini.',
        icon: Icons.soup_kitchen_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        // Kartu item donasi – tampilan menggunakan Card sesuai design BagiRasa
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color.fromRGBO(0, 0, 0, 0.06)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(45, 90, 61, 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.soup_kitchen_rounded,
                color: Color(0xFF2D5A3D),
              ),
            ),
            title: Text(
              item.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E3230),
              ),
            ),
            subtitle: Text(
              item.subtitle,
              style: const TextStyle(color: Color(0xFF5A605B), fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF2D5A3D)),
            // (7) kirim item yang dipilih ke layar Detail
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.detail, arguments: item),
          ),
        );
      },
    );
  }
}
