import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:first_project/features/lokasi/data/pickup_point.dart';
import 'package:first_project/features/lokasi/data/pickup_point_repository.dart';
import 'package:first_project/features/lokasi/logic/pickup_point_form_notifier.dart';

void main() {
  group('PickupPointFormNotifier', () {
    test('Initializes with default values in create mode', () {
      final notifier = PickupPointFormNotifier();

      expect(notifier.isEdit, isFalse);
      expect(notifier.name, isEmpty);
      expect(notifier.address, isEmpty);
      expect(notifier.openTime, '13:00');
      expect(notifier.closeTime, '16:30');
      expect(notifier.latitude, kCampusCenterLat);
      expect(notifier.longitude, kCampusCenterLng);
      expect(notifier.autoActivate, isTrue);
    });

    test('Initializes with prefilled values in edit mode', () {
      const existing = PickupPoint(
        id: 'test-1',
        name: 'Kantin FEB',
        address: 'Gedung FEB Unand',
        latitude: -0.9145,
        longitude: 100.4595,
        openTime: '08:00',
        closeTime: '15:00',
        note: 'Pintu samping',
        status: PickupPointStatus.tutup,
      );

      final notifier = PickupPointFormNotifier(point: existing);

      expect(notifier.isEdit, isTrue);
      expect(notifier.name, 'Kantin FEB');
      expect(notifier.address, 'Gedung FEB Unand');
      expect(notifier.openTime, '08:00');
      expect(notifier.closeTime, '15:00');
      expect(notifier.latitude, -0.9145);
      expect(notifier.longitude, 100.4595);
      expect(notifier.note, 'Pintu samping');
      expect(notifier.autoActivate, isFalse);
    });

    test('Validation fails when required fields are empty', () {
      final notifier = PickupPointFormNotifier();

      final isValid = notifier.validate();

      expect(isValid, isFalse);
      expect(notifier.nameError, isNotNull);
      expect(notifier.addressError, isNotNull);
    });

    test('Validation fails when close time is earlier than or equal to open time', () {
      final notifier = PickupPointFormNotifier();
      notifier.setName('Kantin Sisfo');
      notifier.setAddress('Gedung FTI');
      notifier.setOpenTime(const TimeOfDay(hour: 16, minute: 0));
      notifier.setCloseTime(const TimeOfDay(hour: 14, minute: 0));

      final isValid = notifier.validate();

      expect(isValid, isFalse);
      expect(notifier.timeError, 'Jam tutup harus lebih lambat dari jam buka');
    });

    test('Validation passes when all fields are valid', () {
      final notifier = PickupPointFormNotifier();
      notifier.setName('Kantin Sisfo');
      notifier.setAddress('Gedung FTI');
      notifier.setOpenTime(const TimeOfDay(hour: 10, minute: 0));
      notifier.setCloseTime(const TimeOfDay(hour: 16, minute: 0));

      final isValid = notifier.validate();

      expect(isValid, isTrue);
      expect(notifier.nameError, isNull);
      expect(notifier.addressError, isNull);
      expect(notifier.timeError, isNull);
      expect(notifier.pinError, isNull);
    });

    test('Save adds new point to repository in create mode', () {
      final repo = PickupPointRepository();
      final initialCount = repo.getAll().length;

      final notifier = PickupPointFormNotifier();
      notifier.setName('Kantin Baru');
      notifier.setAddress('Gedung Baru');
      notifier.setOpenTime(const TimeOfDay(hour: 8, minute: 0));
      notifier.setCloseTime(const TimeOfDay(hour: 15, minute: 0));

      final saved = notifier.save(repo);

      expect(repo.getAll().length, initialCount + 1);
      expect(saved.name, 'Kantin Baru');
      expect(saved.address, 'Gedung Baru');
      expect(saved.status, PickupPointStatus.aktif);
    });

    test('Save updates existing point in repository in edit mode', () {
      final repo = PickupPointRepository();
      final existing = repo.getAll().first;

      final notifier = PickupPointFormNotifier(point: existing);
      notifier.setName('Kantin Updated');
      notifier.setAddress('Alamat Updated');

      final updated = notifier.save(repo);

      expect(repo.getById(existing.id)!.name, 'Kantin Updated');
      expect(repo.getById(existing.id)!.address, 'Alamat Updated');
      expect(updated.id, existing.id);
    });

    test('Toggle auto-activate flips status', () {
      final notifier = PickupPointFormNotifier();
      expect(notifier.autoActivate, isTrue);

      notifier.toggleAutoActivate();
      expect(notifier.autoActivate, isFalse);

      notifier.toggleAutoActivate();
      expect(notifier.autoActivate, isTrue);
    });
  });
}
