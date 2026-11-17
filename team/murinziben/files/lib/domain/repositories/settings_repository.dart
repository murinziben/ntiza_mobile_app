import '../entities/app_settings.dart';

/// Local (on-device) preferences.
abstract class SettingsRepository {
  AppSettings load();
  Future<void> save(AppSettings settings);
}
