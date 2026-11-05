import '../entities/course.dart';
import '../entities/equipment.dart';
import '../entities/expert.dart';

/// Equipment, experts and courses.
abstract class CatalogRepository {
  Stream<List<Equipment>> watchEquipment();
  Future<String> addEquipment(Equipment equipment);
  Future<void> updateEquipment(Equipment equipment);
  Future<void> deleteEquipment(String id);

  Stream<List<Expert>> watchExperts();
  Future<void> saveExpert(Expert expert);

  Stream<List<Course>> watchCourses();
}
