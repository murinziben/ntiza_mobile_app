import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/ui.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
  'September', 'October', 'November', 'December'
];

/// First day of the current month — the calendar's starting page.
DateTime currentMonthStart() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, 1);
}

/// Tomorrow at midnight — the default selected service date.
DateTime tomorrow() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day + 1);
}

/// Stateless month calendar. The owner screen keeps [month] and [selected] in
/// providers and passes callbacks, so this widget needs no State of its own.
class CalendarCard extends StatelessWidget {
  const CalendarCard({
    super.key,
    required this.month,
    required this.selected,
    required this.onMonthChanged,
    required this.onSelected,
    this.isEnabled,
  });

  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onSelected;

  /// Extra rule for selectable days (e.g. an expert's working days).
  final bool Function(DateTime day)? isEnabled;

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(month.year, month.month, 1).weekday; // 1 = Monday
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final cells = <int?>[
      for (var i = 1; i < firstWeekday; i++) null,
      for (var d = 1; d <= daysInMonth; d++) d,
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: () => onMonthChanged(DateTime(month.year, month.month - 1, 1)),
                icon: const Icon(Icons.chevron_left),
              ),
              Text('${_monthNames[month.month - 1]} ${month.year}',
                  style: const TextStyle(fontSize: 17.5, fontWeight: FontWeight.w700)),
              IconButton(
                tooltip: 'Next month',
                onPressed: () => onMonthChanged(DateTime(month.year, month.month + 1, 1)),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Row(
            children: [
              for (final d in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                Expanded(
                  child: Center(
                    child: Text(d, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (var r = 0; r < cells.length ~/ 7; r++)
            Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(child: _dayCell(cells[r * 7 + c], today)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _dayCell(int? d, DateTime today) {
    if (d == null) return const SizedBox(height: 48);
    final date = DateTime(month.year, month.month, d);
    final on = !date.isBefore(today) && (isEnabled?.call(date) ?? true);
    final isSelected = date == selected;
    return Semantics(
      button: true,
      enabled: on,
      label: dayMonth(date),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: on ? () => onSelected(date) : null,
        child: Container(
          height: 48,
          margin: const EdgeInsets.all(2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$d',
              style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : on
                          ? AppColors.ink
                          : AppColors.faint)),
        ),
      ),
    );
  }
}
