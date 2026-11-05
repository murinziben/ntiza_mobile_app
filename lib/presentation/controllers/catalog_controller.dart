import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/entities/expert.dart';
import '../providers/data_providers.dart';
import '../providers/dependencies.dart';
import 'action_notifier.dart';

/// Create / update / delete for equipment, plus expert availability.
class CatalogController extends ActionNotifier {
  /// Saves a new machine for the signed-in owner (blank [existing]) or
  /// updates [existing]. [priceText] is the raw text of the price field.
  Future<ActionResult<void>> saveEquipment({
    Equipment? existing,
    required String name,
    required String type,
    required String priceText,
    required String unit,
    required String district,
    required String sector,
    required String about,
  }) =>
      run(() async {
        final me = ref.read(profileProvider).valueOrNull;
        if (me == null) throw const AppException('Please log in again.');
        final price = int.tryParse(priceText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final equipment = existing == null
            ? Equipment(
                id: '',
                ownerId: me.uid,
                ownerName: me.name,
                name: name.trim(),
                type: type,
                district: district.trim(),
                sector: sector.trim(),
                price: price,
                unit: unit,
                about: about.trim(),
              )
            : existing.copyWith(
                name: name.trim(),
                type: type,
                district: district.trim(),
                sector: sector.trim(),
                price: price,
                unit: unit,
                about: about.trim(),
              );
        await ref.read(catalogUseCasesProvider).saveEquipment(equipment, priceText: priceText);
      });

  Future<ActionResult<void>> deleteEquipment(Equipment equipment) => run(() async {
        final bookings = ref.read(providerBookingsProvider).valueOrNull ?? const [];
        await ref.read(catalogUseCasesProvider).deleteEquipment(equipment, bookings);
      });

  Future<ActionResult<void>> setEquipmentStatus(Equipment equipment, String status) =>
      run(() => ref.read(catalogUseCasesProvider).setEquipmentStatus(equipment, status));

  Future<ActionResult<void>> saveAvailability(Expert expert) =>
      run(() => ref.read(catalogUseCasesProvider).saveAvailability(expert));
}

final catalogControllerProvider =
    NotifierProvider<CatalogController, ActionState>(CatalogController.new);
