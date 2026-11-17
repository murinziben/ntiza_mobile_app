import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/course.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/entities/expert.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../mappers/firestore_mappers.dart';
import 'firebase_errors.dart';

/// Equipment, experts and courses stored in Cloud Firestore.
class FirestoreCatalogRepository implements CatalogRepository {
  FirestoreCatalogRepository(this._db);

  final FirebaseFirestore _db;

  @override
  Stream<List<Equipment>> watchEquipment() => _db.collection('equipment').snapshots().map(
        (q) => [for (final d in q.docs) equipmentFromMap(d.id, d.data())],
      );

  @override
  Future<String> addEquipment(Equipment e) => guardData(() async {
        final doc = await _db.collection('equipment').add(equipmentCreateMap(e));
        return doc.id;
      });

  @override
  Future<void> updateEquipment(Equipment e) =>
      guardData(() => _db.collection('equipment').doc(e.id).update(equipmentToMap(e)));

  @override
  Future<void> deleteEquipment(String id) =>
      guardData(() => _db.collection('equipment').doc(id).delete());

  @override
  Stream<List<Expert>> watchExperts() => _db.collection('experts').snapshots().map(
        (q) => [for (final d in q.docs) expertFromMap(d.id, d.data())],
      );

  @override
  Future<void> saveExpert(Expert x) => guardData(
        () => _db.collection('experts').doc(x.id).set(expertToMap(x), SetOptions(merge: true)),
      );

  @override
  Stream<List<Course>> watchCourses() => _db.collection('courses').snapshots().map(
        (q) => [for (final d in q.docs) courseFromMap(d.id, d.data())],
      );
}
