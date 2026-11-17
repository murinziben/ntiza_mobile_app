import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/agent_client.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/role.dart';
import '../providers/data_providers.dart';
import '../providers/dependencies.dart';
import 'action_notifier.dart';

/// Back-office actions for admins, plus agent-client management and
/// notification housekeeping (small controllers share this file's pattern).
class AdminController extends ActionNotifier {
  Future<ActionResult<void>> decideApplication(AppUser user, {required bool approve}) =>
      run(() async {
        await ref.read(adminRepositoryProvider).decideApplication(user, approve: approve);
        await ref.read(notificationRepositoryProvider).add(
              user.uid,
              approve ? 'Application approved' : 'Application not approved',
              approve
                  ? 'Welcome to NTIZA. You can now use your ${user.role.label} account.'
                  : 'Your ${user.role.label} application was not approved.',
              'booking',
            );
      });

  Future<ActionResult<void>> setUserStatus(AppUser user, String status) =>
      run(() => ref.read(adminRepositoryProvider).setUserStatus(user.uid, status));

  Future<ActionResult<void>> deleteUser(AppUser user) =>
      run(() => ref.read(adminRepositoryProvider).deleteUser(user.uid));

  Future<ActionResult<void>> resolveDispute(String id, String resolution) => run(() async {
        if (resolution.trim().isEmpty) {
          throw const AppException('Write a short resolution note first.');
        }
        await ref.read(adminRepositoryProvider).resolveDispute(id, resolution.trim());
      });

  Future<ActionResult<void>> deleteDispute(String id) =>
      run(() => ref.read(adminRepositoryProvider).deleteDispute(id));

  Future<ActionResult<void>> seedDemoData() =>
      run(() => ref.read(adminRepositoryProvider).seedDemoData());
}

final adminControllerProvider =
    NotifierProvider<AdminController, ActionState>(AdminController.new);

/// Add, edit and remove the farmers an agent books for.
class AgentController extends ActionNotifier {
  Future<ActionResult<void>> saveClient({
    AgentClient? existing,
    required String name,
    required String phone,
    required String district,
  }) =>
      run(() async {
        final agentId = ref.read(currentUidProvider);
        if (agentId == null) throw const AppException('Please log in again.');
        final client = existing?.copyWith(name: name, phone: phone, district: district) ??
            AgentClient(id: '', agentId: agentId, name: name, phone: phone, district: district);
        await ref.read(agentUseCasesProvider).saveClient(client);
      });

  Future<ActionResult<void>> deleteClient(AgentClient client) =>
      run(() => ref.read(agentUseCasesProvider).deleteClient(client.id));
}

final agentControllerProvider =
    NotifierProvider<AgentController, ActionState>(AgentController.new);

/// Mark-as-read and delete for the notification list.
class NotificationController extends ActionNotifier {
  Future<ActionResult<void>> markRead(AppNotification n) => run(() async {
        if (n.unread) await ref.read(notificationRepositoryProvider).markRead(n.id);
      });

  Future<ActionResult<void>> markAllRead() => run(() async {
        final uid = ref.read(currentUidProvider);
        if (uid != null) await ref.read(notificationRepositoryProvider).markAllRead(uid);
      });

  Future<ActionResult<void>> delete(AppNotification n) =>
      run(() => ref.read(notificationRepositoryProvider).delete(n.id));
}

final notificationControllerProvider =
    NotifierProvider<NotificationController, ActionState>(NotificationController.new);
