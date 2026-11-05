import '../../core/errors/app_exception.dart';
import '../entities/booking.dart';
import '../entities/equipment.dart';
import '../entities/expert.dart';
import '../repositories/catalog_repository.dart';
import '../validators.dart';

/// Rules for listing, editing and removing equipment and expert profiles.
class CatalogUseCases {
  CatalogUseCases(this._catalog);

  final CatalogRepository _catalog;

  /// Validates and saves; creates when [Equipment.id] is empty, otherwise updates.
  Future<void> saveEquipment(Equipment equipment, {required String priceText}) async {
    final error = Validators.required(equipment.name, 'Equipment name') ??
        Validators.price(priceText) ??
        Validators.required(equipment.district, 'District');
    if (error != null) throw AppException(error);
    if (equipment.id.isEmpty) {
      await _catalog.addEquipment(equipment);
    } else {
      await _catalog.updateEquipment(equipment);
    }
  }

  /// Equipment with a pending or confirmed booking cannot be removed.
  Future<void> deleteEquipment(Equipment equipment, Iterable<Booking> bookings) async {
    final busy = bookings.any((b) =>
        b.itemId == equipment.id &&
        (b.status == BookingStatus.pending || b.status == BookingStatus.confirmed));
    if (busy) {
      throw const AppException('Finish or decline the open bookings on this machine first.');
    }
    await _catalog.deleteEquipment(equipment.id);
  }

  Future<void> setEquipmentStatus(Equipment equipment, String status) =>
      _catalog.updateEquipment(equipment.copyWith(status: status));

  Future<void> saveAvailability(Expert expert) async {
    if (expert.fee <= 0) throw const AppException('Enter a fee greater than zero.');
    if (expert.sessionMinutes <= 0) {
      throw const AppException('Enter a session length in minutes.');
    }
    await _catalog.saveExpert(expert);
  }
}
