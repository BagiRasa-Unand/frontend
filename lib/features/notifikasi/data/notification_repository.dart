import 'package:flutter/foundation.dart';

import 'app_notification.dart';

class NotificationRepository extends ChangeNotifier {
  NotificationRepository() : _items = _seed(DateTime.now());

  final List<AppNotification> _items;

  List<AppNotification> getAll() => List.unmodifiable(_items);

  int get unreadCount => _items.where((item) => !item.isRead).length;

  void add(AppNotification notification) {
    _items.insert(0, notification);
    notifyListeners();
  }

  void markRead(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1 || _items[index].isRead) return;
    _items[index] = _items[index].copyWith(isRead: true);
    notifyListeners();
  }

  void markAllRead() {
    var changed = false;
    for (var index = 0; index < _items.length; index++) {
      if (!_items[index].isRead) {
        _items[index] = _items[index].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  static List<AppNotification> _seed(DateTime now) {
    return [
      AppNotification(
        id: 'notification-001',
        type: AppNotificationType.newListing,
        title: 'Listing baru: Nasi Kotak di Kantin Sisfo',
        body: 'Kantin Sisfo baru saja membagikan 15 porsi Nasi Kotak Ayam.',
        createdAt: now.subtract(const Duration(minutes: 5)),
        isRead: false,
        refId: 'food-001',
      ),
      AppNotification(
        id: 'notification-002',
        type: AppNotificationType.claimStatus,
        title: 'Klaim berhasil dikonfirmasi!',
        body: 'Kode klaimmu #BGR-9482 telah siap diambil di Kantin Rektorat.',
        createdAt: now.subtract(const Duration(minutes: 18)),
        isRead: false,
      ),
      AppNotification(
        id: 'notification-003',
        type: AppNotificationType.reminder,
        title: 'Pengingat: Waktu Pengambilan',
        body: 'Pesanan donasi Nasi Bento akan segera melewati batas pengambilan.',
        createdAt: now.subtract(const Duration(hours: 1)),
        isRead: true,
      ),
      AppNotification(
        id: 'notification-004',
        type: AppNotificationType.newListing,
        title: 'Listing baru: Buah Potong Segar',
        body: 'Ada makanan surplus baru yang bisa kamu selamatkan di kampus.',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
        refId: 'food-006',
      ),
    ];
  }
}