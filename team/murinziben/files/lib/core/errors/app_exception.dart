/// An error whose [message] is safe and friendly enough to show to the user.
///
/// The data layer converts low-level failures (Firebase codes, network
/// problems) into this type so the presentation layer never has to know about
/// the backend.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}
