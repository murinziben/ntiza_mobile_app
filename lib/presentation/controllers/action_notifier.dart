import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';

/// UI state of a controller: whether a request is in flight.
class ActionState {
  const ActionState({this.busy = false});
  final bool busy;
}

/// The outcome of a controller action — a value, or a message to show.
class ActionResult<T> {
  const ActionResult.ok([this.value]) : error = null;
  const ActionResult.fail(String message)
      : value = null,
        error = message;

  final T? value;
  final String? error;
  bool get ok => error == null;
}

/// Base class for controllers. [run] sets `busy` while the job runs, catches
/// failures and returns them as a friendly message, so screens never need
/// try/catch or `setState`.
abstract class ActionNotifier extends Notifier<ActionState> {
  @override
  ActionState build() => const ActionState();

  Future<ActionResult<T>> run<T>(Future<T> Function() job) async {
    state = const ActionState(busy: true);
    try {
      return ActionResult<T>.ok(await job());
    } on AppException catch (e) {
      return ActionResult<T>.fail(e.message);
    } catch (_) {
      return ActionResult<T>.fail('Something went wrong. Please try again.');
    } finally {
      state = const ActionState();
    }
  }
}
