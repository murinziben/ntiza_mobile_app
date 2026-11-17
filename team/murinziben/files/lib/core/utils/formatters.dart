/// Formats a whole number of francs as `RWF 25,000`.
String rwf(num value) {
  final digits = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return 'RWF $buffer';
}

/// Up to two initials for an avatar, ignoring honorifics such as `Dr.`.
String initialsOf(String name) {
  final parts = name
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty && !p.endsWith('.'))
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

const List<String> shortMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

const List<String> weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

/// `now`, `5m`, `3h`, `Yesterday` or `12 Nov` — used by the notification list.
String timeAgo(DateTime time, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(time);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inHours < 48) return 'Yesterday';
  return '${time.day} ${shortMonths[time.month - 1]}';
}

/// `05 Nov` style label.
String dayMonth(DateTime t) =>
    '${t.day.toString().padLeft(2, '0')} ${shortMonths[t.month - 1]}';

/// Compact money for dashboards: `412K`, `1.20M`.
String compactRwf(num value) => value >= 1000000
    ? '${(value / 1000000).toStringAsFixed(2)}M'
    : '${(value / 1000).round()}K';
