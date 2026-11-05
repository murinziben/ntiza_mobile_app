import '../../core/utils/formatters.dart';

/// An agricultural expert — the `experts/{uid}` document.
class Expert {
  const Expert({
    required this.id,
    required this.name,
    required this.field,
    required this.category,
    this.rating = 0,
    this.years = 0,
    this.fee = 15000,
    this.sessionMinutes = 30,
    this.accepting = true,
    this.schedule = const {},
  });

  final String id;
  final String name;
  final String field;
  final String category;
  final double rating;
  final int years;

  /// Price of one session in RWF.
  final int fee;
  final int sessionMinutes;

  /// Whether farmers can currently book this expert.
  final bool accepting;

  /// Weekday name → opening hours; an empty string means unavailable.
  final Map<String, String> schedule;

  /// The schedule for every weekday, filling gaps with "unavailable".
  Map<String, String> get fullSchedule =>
      {for (final d in weekdayNames) d: schedule[d] ?? ''};

  Expert copyWith({
    int? fee,
    int? sessionMinutes,
    bool? accepting,
    Map<String, String>? schedule,
  }) =>
      Expert(
        id: id,
        name: name,
        field: field,
        category: category,
        rating: rating,
        years: years,
        fee: fee ?? this.fee,
        sessionMinutes: sessionMinutes ?? this.sessionMinutes,
        accepting: accepting ?? this.accepting,
        schedule: schedule ?? this.schedule,
      );
}

/// Default opening hours given to a newly approved expert.
const Map<String, String> defaultExpertSchedule = {
  'Monday': '08:00 – 12:00',
  'Tuesday': '08:00 – 12:00',
  'Wednesday': '09:00 – 16:00',
  'Friday': '08:00 – 12:00',
};
