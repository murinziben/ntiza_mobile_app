import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntiza/data/mappers/firestore_mappers.dart';
import 'package:ntiza/domain/entities/entities.dart';

void main() {
  final stamp = Timestamp.fromDate(DateTime(2026, 11, 2, 9, 30));

  test('user round trip keeps the ERD fields', () {
    final user = userFromMap('u1', {
      'name': 'Uwase Esperance',
      'email': 'e@example.com',
      'phone': '0781234567',
      'district': 'Huye',
      'role': 'owner',
      'status': 'pending',
      'createdAt': stamp,
    });
    expect(user.role, Role.owner);
    expect(user.isActive, isFalse);
    expect(user.createdAt, DateTime(2026, 11, 2, 9, 30));
  });

  test('user defaults when fields are missing', () {
    final user = userFromMap('u2', {});
    expect(user.role, Role.farmer);
    expect(user.status, UserStatus.active);
    expect(user.name, isEmpty);
  });

  test('equipment mapping including specs', () {
    final e = equipmentFromMap('eq1', {
      'ownerId': 'o1',
      'ownerName': 'Agasaro',
      'name': 'Tractor',
      'type': 'Tractor',
      'district': 'Huye',
      'sector': 'Mbazi',
      'price': 25000,
      'unit': 'hour',
      'status': 'Booked',
      'about': 'Big',
      'jobs': 3,
      'specs': [
        {'k': 'Power', 'v': '50 HP'},
        'ignored',
      ],
    });
    expect(e.available, isFalse);
    expect(e.specs.single.key, 'Power');
    expect(e.jobs, 3);
    final map = equipmentToMap(e);
    expect(map['specs'], [
      {'k': 'Power', 'v': '50 HP'}
    ]);
    expect(map.containsKey('jobs'), isFalse);
  });

  test('expert mapping with schedule', () {
    final x = expertFromMap('ex1', {
      'name': 'Dr. Uwera',
      'field': 'Crops',
      'category': 'Crops',
      'rating': 4.9,
      'years': 12,
      'fee': 20000,
      'sessionMinutes': 45,
      'accepting': false,
      'schedule': {'Monday': '08:00 – 12:00'},
    });
    expect(x.rating, 4.9);
    expect(x.accepting, isFalse);
    expect(x.schedule['Monday'], '08:00 – 12:00');
    expect(expertToMap(x)['fee'], 20000);
    final d = expertFromMap('ex2', {});
    expect(d.fee, 15000);
    expect(d.accepting, isTrue);
  });

  test('course round trip', () {
    final c = courseFromMap('c1', {'title': 'T', 'level': 'Beginner', 'topic': 'x', 'lessons': 5, 'image': 'a.jpg'});
    expect(courseToMap(c)['lessons'], 5);
  });

  test('booking mapping', () {
    final b = bookingFromMap('NTZ-2041', {
      'kind': 'consult',
      'title': 'Maize',
      'status': 'Confirmed',
      'total': 15000,
      'farmerId': 'f1',
      'providerId': 'p1',
      'paidVia': 'MTN MoMo',
      'createdAt': stamp,
    });
    expect(b.expert, isTrue);
    expect(b.isPaid, isTrue);
    expect(b.created, '02 Nov');
    expect(bookingFromMap('x', {}).createdAt, isNull);
  });

  test('notification, dispute and client mappers', () {
    final n = notificationFromMap('n1', {'userId': 'u', 'title': 'T', 'body': 'B', 'unread': false});
    expect(n.unread, isFalse);
    final d = disputeFromMap('d1', {'bookingRef': 'NTZ-1', 'reason': 'late', 'status': 'Resolved'});
    expect(d.isOpen, isFalse);
    expect(d.bookingRef, 'NTZ-1');
    final c = clientFromMap('c1', {'agentId': 'a', 'name': 'N', 'phone': '07', 'district': 'Huye'});
    expect(clientToMap(c)['agentId'], 'a');
  });
}
