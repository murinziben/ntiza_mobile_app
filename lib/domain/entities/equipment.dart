/// One line of an equipment specification sheet, e.g. `Power` → `50 HP`.
class Spec {
  const Spec(this.key, this.value);
  final String key;
  final String value;
}

/// Allowed values of `equipment.status`.
class EquipmentStatus {
  EquipmentStatus._();
  static const available = 'Available';
  static const booked = 'Booked';
  static const maintenance = 'Maintenance';
  static const all = [available, booked, maintenance];
}

const equipmentTypes = ['Tractor', 'Harvester', 'Planter', 'Pump', 'Tiller', 'Sheller'];
const equipmentUnits = ['hour', 'day', 'hectare'];

/// Asset photo used for a machine of the given [type].
String imageForType(String type) => switch (type) {
      'Harvester' || 'Sheller' => 'harvester.jpg',
      'Planter' => 'planter.jpg',
      'Pump' => 'pump.jpg',
      'Tiller' => 'tiller.jpg',
      _ => 'tractor.jpg',
    };

/// A machine that can be hired — the `equipment/{id}` document.
class Equipment {
  const Equipment({
    required this.id,
    required this.name,
    required this.type,
    required this.district,
    required this.price,
    required this.unit,
    this.sector = '',
    this.ownerId = '',
    this.ownerName = '',
    this.status = EquipmentStatus.available,
    this.about = '',
    this.jobs = 0,
    this.specs = const [],
  });

  final String id;
  final String name;
  final String type;
  final String district;
  final String sector;
  final int price;

  /// `hour`, `day` or `hectare`.
  final String unit;
  final String ownerId;
  final String ownerName;
  final String status;
  final String about;

  /// Completed jobs — a counter maintained when a booking is completed.
  final int jobs;
  final List<Spec> specs;

  String get image => imageForType(type);
  String get place => sector.isEmpty ? district : '$district · $sector';
  bool get available => status == EquipmentStatus.available;
  String get statusLabel => status;

  /// `hr`, `day` or `ha` for compact price lines.
  String get unitShort => switch (unit) {
        'hour' => 'hr',
        'hectare' => 'ha',
        _ => 'day',
      };

  Equipment copyWith({
    String? name,
    String? type,
    String? district,
    String? sector,
    int? price,
    String? unit,
    String? status,
    String? about,
    String? ownerName,
    String? id,
  }) =>
      Equipment(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        district: district ?? this.district,
        sector: sector ?? this.sector,
        price: price ?? this.price,
        unit: unit ?? this.unit,
        ownerId: ownerId,
        ownerName: ownerName ?? this.ownerName,
        status: status ?? this.status,
        about: about ?? this.about,
        jobs: jobs,
        specs: specs,
      );
}
