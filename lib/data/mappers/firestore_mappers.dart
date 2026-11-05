import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/agent_client.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/dispute.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/entities/expert.dart';
import '../../domain/entities/role.dart';
import '../../domain/repositories/booking_repository.dart';

/// Converts between Firestore documents (maps) and domain entities.
/// Keeping this in one place means field names are defined exactly once and
/// match the ERD in `docs/ERD.md`.

String _s(Map<String, dynamic> m, String key, [String fallback = '']) {
  final v = m[key];
  return v == null ? fallback : v.toString();
}

int _i(Map<String, dynamic> m, String key, [int fallback = 0]) {
  final v = m[key];
  return v is num ? v.toInt() : fallback;
}

DateTime? _ts(Object? v) => v is Timestamp ? v.toDate() : null;

// ---- users -----------------------------------------------------------------

AppUser userFromMap(String id, Map<String, dynamic> m) => AppUser(
      uid: id,
      name: _s(m, 'name'),
      email: _s(m, 'email'),
      phone: _s(m, 'phone'),
      district: _s(m, 'district'),
      role: roleFromName(m['role'] as String?),
      status: _s(m, 'status', UserStatus.active),
      createdAt: _ts(m['createdAt']),
    );

Map<String, dynamic> userToMap(AppUser u) => {
      'name': u.name,
      'email': u.email,
      'phone': u.phone,
      'district': u.district,
      'role': u.role.name,
      'status': u.status,
      'createdAt': FieldValue.serverTimestamp(),
    };

// ---- equipment -------------------------------------------------------------

Equipment equipmentFromMap(String id, Map<String, dynamic> m) => Equipment(
      id: id,
      ownerId: _s(m, 'ownerId'),
      ownerName: _s(m, 'ownerName'),
      name: _s(m, 'name'),
      type: _s(m, 'type'),
      district: _s(m, 'district'),
      sector: _s(m, 'sector'),
      price: _i(m, 'price'),
      unit: _s(m, 'unit', 'hour'),
      status: _s(m, 'status', EquipmentStatus.available),
      about: _s(m, 'about'),
      jobs: _i(m, 'jobs'),
      specs: [
        for (final raw in (m['specs'] as List? ?? const []))
          if (raw is Map) Spec((raw['k'] ?? '').toString(), (raw['v'] ?? '').toString()),
      ],
    );

/// Fields written when equipment is created or edited. `jobs` and
/// `createdAt` are only set on creation (see [equipmentCreateMap]).
Map<String, dynamic> equipmentToMap(Equipment e) => {
      'ownerId': e.ownerId,
      'ownerName': e.ownerName,
      'name': e.name,
      'type': e.type,
      'district': e.district,
      'sector': e.sector,
      'price': e.price,
      'unit': e.unit,
      'status': e.status,
      'about': e.about,
      'specs': [for (final s in e.specs) {'k': s.key, 'v': s.value}],
    };

Map<String, dynamic> equipmentCreateMap(Equipment e) => {
      ...equipmentToMap(e),
      'jobs': e.jobs,
      'createdAt': FieldValue.serverTimestamp(),
    };

// ---- experts ---------------------------------------------------------------

Expert expertFromMap(String id, Map<String, dynamic> m) => Expert(
      id: id,
      name: _s(m, 'name'),
      field: _s(m, 'field'),
      category: _s(m, 'category'),
      rating: (m['rating'] is num) ? (m['rating'] as num).toDouble() : 0,
      years: _i(m, 'years'),
      fee: _i(m, 'fee', 15000),
      sessionMinutes: _i(m, 'sessionMinutes', 30),
      accepting: m['accepting'] is bool ? m['accepting'] as bool : true,
      schedule: {
        if (m['schedule'] is Map)
          for (final e in (m['schedule'] as Map).entries) e.key.toString(): e.value.toString(),
      },
    );

Map<String, dynamic> expertToMap(Expert x) => {
      'name': x.name,
      'field': x.field,
      'category': x.category,
      'rating': x.rating,
      'years': x.years,
      'fee': x.fee,
      'sessionMinutes': x.sessionMinutes,
      'accepting': x.accepting,
      'schedule': x.schedule,
    };

// ---- courses ---------------------------------------------------------------

Course courseFromMap(String id, Map<String, dynamic> m) => Course(
      id: id,
      title: _s(m, 'title'),
      level: _s(m, 'level', 'Beginner'),
      topic: _s(m, 'topic'),
      lessons: _i(m, 'lessons'),
      image: _s(m, 'image'),
    );

Map<String, dynamic> courseToMap(Course c) => {
      'title': c.title,
      'level': c.level,
      'topic': c.topic,
      'lessons': c.lessons,
      'image': c.image,
    };

// ---- bookings --------------------------------------------------------------

Booking bookingFromMap(String id, Map<String, dynamic> m) => Booking(
      ref: id,
      kind: _s(m, 'kind', BookingKind.equipment),
      title: _s(m, 'title'),
      image: _s(m, 'image'),
      status: _s(m, 'status', BookingStatus.pending),
      dateLabel: _s(m, 'dateLabel'),
      detail: _s(m, 'detail'),
      place: _s(m, 'place'),
      total: _i(m, 'total'),
      farmerId: _s(m, 'farmerId'),
      farmerName: _s(m, 'farmerName'),
      providerId: _s(m, 'providerId'),
      providerName: _s(m, 'providerName'),
      itemId: _s(m, 'itemId'),
      scheduled: _s(m, 'scheduled'),
      location: _s(m, 'location'),
      paidVia: m['paidVia'] as String?,
      agentId: _s(m, 'agentId'),
      clientName: _s(m, 'clientName'),
      createdAt: _ts(m['createdAt']),
    );

Map<String, dynamic> newBookingToMap(NewBooking b) => {
      'kind': b.kind,
      'title': b.title,
      'image': b.image,
      'status': BookingStatus.pending,
      'dateLabel': b.dateLabel,
      'scheduled': b.scheduled,
      'detail': b.detail,
      'place': b.place,
      'location': b.location,
      'total': b.total,
      'itemId': b.itemId,
      'farmerId': b.farmerId,
      'farmerName': b.farmerName,
      'providerId': b.providerId,
      'providerName': b.providerName,
      'agentId': b.agentId,
      'clientName': b.clientName,
      'createdAt': FieldValue.serverTimestamp(),
    };

// ---- notifications ---------------------------------------------------------

AppNotification notificationFromMap(String id, Map<String, dynamic> m) => AppNotification(
      id: id,
      userId: _s(m, 'userId'),
      title: _s(m, 'title'),
      body: _s(m, 'body'),
      kind: _s(m, 'kind', 'booking'),
      unread: m['unread'] is bool ? m['unread'] as bool : true,
      createdAt: _ts(m['createdAt']),
    );

Map<String, dynamic> notificationToMap(String userId, String title, String body, String kind) => {
      'userId': userId,
      'title': title,
      'body': body,
      'kind': kind,
      'unread': true,
      'createdAt': FieldValue.serverTimestamp(),
    };

// ---- disputes --------------------------------------------------------------

Dispute disputeFromMap(String id, Map<String, dynamic> m) => Dispute(
      id: id,
      bookingRef: _s(m, 'bookingRef'),
      raisedBy: _s(m, 'raisedBy'),
      raisedByName: _s(m, 'raisedByName'),
      reason: _s(m, 'reason'),
      status: _s(m, 'status', Dispute.open),
      resolution: _s(m, 'resolution'),
      createdAt: _ts(m['createdAt']),
    );

Map<String, dynamic> disputeToMap(Dispute d) => {
      'bookingRef': d.bookingRef,
      'raisedBy': d.raisedBy,
      'raisedByName': d.raisedByName,
      'reason': d.reason,
      'status': d.status,
      'resolution': d.resolution,
      'createdAt': FieldValue.serverTimestamp(),
    };

// ---- agent clients ---------------------------------------------------------

AgentClient clientFromMap(String id, Map<String, dynamic> m) => AgentClient(
      id: id,
      agentId: _s(m, 'agentId'),
      name: _s(m, 'name'),
      phone: _s(m, 'phone'),
      district: _s(m, 'district'),
      createdAt: _ts(m['createdAt']),
    );

Map<String, dynamic> clientToMap(AgentClient c) => {
      'agentId': c.agentId,
      'name': c.name,
      'phone': c.phone,
      'district': c.district,
    };
