/// User preferences that survive an app restart (SharedPreferences).
class AppSettings {
  const AppSettings({
    this.textScale = 1.0,
    this.notificationsEnabled = true,
    this.preferredDistrict = '',
    this.rememberedEmail = '',
    this.onboardingSeen = false,
  });

  /// Text size multiplier: 0.9 small, 1.0 normal, 1.15 large.
  final double textScale;

  /// Whether the notification badge and list are shown.
  final bool notificationsEnabled;

  /// District the marketplace is pre-filtered to; empty means all of Rwanda.
  final String preferredDistrict;

  /// E-mail pre-filled on the login screen when "Remember me" is on.
  final String rememberedEmail;

  /// True once the welcome screen has been dismissed.
  final bool onboardingSeen;

  AppSettings copyWith({
    double? textScale,
    bool? notificationsEnabled,
    String? preferredDistrict,
    String? rememberedEmail,
    bool? onboardingSeen,
  }) =>
      AppSettings(
        textScale: textScale ?? this.textScale,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        preferredDistrict: preferredDistrict ?? this.preferredDistrict,
        rememberedEmail: rememberedEmail ?? this.rememberedEmail,
        onboardingSeen: onboardingSeen ?? this.onboardingSeen,
      );
}
