import 'package:flutter/foundation.dart';

import 'app_notification.dart';
import 'notification_api_service.dart';

class NotificationRepository extends ChangeNotifier {
  NotificationRepository({NotificationApiService? apiService})
      : _apiService = apiService ?? NotificationApiService(),
        _items = _seed(DateTime.now()) {
    fetchFromApi();
  }

  final NotificationApiService _apiService;
  List<AppNotification> _items;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Memuat notifikasi dari PostgreSQL backend
  Future<void> fetchFromApi() async {
    _isLoading = true;
    notifyListeners();

    try {
      final backendList = await _apiService.getNotifications();
      if (backendList != null && backendList.isNotEmpty) {
        _items = backendList;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[NotificationRepository] Fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

    _apiService.markAsRead(id);
  }

  void markAllRead() {
    var changed = false;
    for (var index = 0; index < _items.length; index++) {
      if (!_items[index].isRead) {
        _items[index] = _items[index].copyWith(isRead: true);
        _apiService.markAsRead(_items[index].id);
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
    ];
  }
}
