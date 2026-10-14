import 'package:flutter/material.dart';
import '../models/pickup_point.dart';
import '../routes/app_routes.dart';

class PickupPointListScreen extends StatefulWidget {
  const PickupPointListScreen({super.key});

  @override
  State<PickupPointListScreen> createState() => _PickupPointListScreenState();
}

class _PickupPointListScreenState extends State<PickupPointListScreen> {
  // STATE
  final List<PickupPoint> _points = [
    const PickupPoint(
      id: '1',
      name: 'Kantin Fakultas Teknik',
      address: 'Gedung Dekanat Teknik, Lantai 1, Kampus Unand Limau Manis',
      latitude: -0.9115,
      longitude: 100.4558,
    ),
    const PickupPoint(
      id: '2',
      name: 'Lobi Gedung PKM',
      address: 'Pusat Kegiatan Mahasiswa, Kampus Unand Limau Manis',
      latitude: -0.9123,
      longitude: 100.4561,
    ),
    const PickupPoint(
      id: '3',
      name: 'Sekretariat BEM Unand',
      address: 'Gedung Rektorat, Lantai 2, Kampus Unand Limau Manis',
      latitude: -0.9108,
      longitude: 100.4549,
    ),
    const PickupPoint(
      id: '4',
      name: 'Kantin Asrama Mahasiswa',
      address: 'Blok A Asrama Putra, Kampus Unand Limau Manis',
      latitude: -0.9131,
      longitude: 100.4572,
    ),
  ];

  // NAVIGATION — buka form edit dan tunggu hasilnya
  Future<void> _bukaEdit(PickupPoint point) async {
    final hasil = await Navigator.pushNamed<PickupPoint>(
      context,
      AppRoutes.editPickupPoint,
      arguments: point,
    );

    // Setelah await, widget bisa saja sudah dibuang
    if (!mounted) return;

    // Jika user menekan Back, hasil null — list tidak diubah
    if (hasil == null) return;

    // STATE — ganti item yang id-nya cocok
    setState(() {
      final idx = _points.indexWhere((p) => p.id == hasil.id);
      if (idx != -1) _points[idx] = hasil;
    });

    // FEEDBACK — SnackBar tampil di list, bukan di form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Titik pengambilan diperbarui')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Titik Pengambilan')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _points.length,
        itemBuilder: (context, index) => _PointCard(
          point: _points[index],
          onEdit: () => _bukaEdit(_points[index]),
        ),
      ),
    );
  }
}

class _PointCard extends StatelessWidget {
  final PickupPoint point;
  final VoidCallback onEdit;

  const _PointCard({required this.point, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(point.name),
        subtitle: Text(point.address),
        trailing: TextButton(onPressed: onEdit, child: const Text('Edit')),
      ),
    );
  }
}
