import '../entities/agent_client.dart';
import '../entities/app_user.dart';
import '../entities/dispute.dart';

/// Back-office operations: users, applications, disputes and demo data.
abstract class AdminRepository {
  Stream<List<AppUser>> watchUsers();

  /// Approve or reject a partner application. Approving an expert also
  /// creates their `experts/{uid}` document.
  Future<void> decideApplication(AppUser user, {required bool approve});

  Future<void> setUserStatus(String uid, String status);

  /// Removes the profile document of another user.
  Future<void> deleteUser(String uid);

  Stream<List<Dispute>> watchDisputes();
  Stream<List<Dispute>> watchDisputesRaisedBy(String uid);
  Future<void> createDispute(Dispute dispute);
  Future<void> resolveDispute(String id, String resolution);
  Future<void> deleteDispute(String id);

  /// Loads sample equipment, experts, courses and users.
  Future<void> seedDemoData();
}

/// The clients an agent books for.
abstract class AgentRepository {
  Stream<List<AgentClient>> watchClients(String agentId);
  Future<void> addClient(AgentClient client);
  Future<void> updateClient(AgentClient client);
  Future<void> deleteClient(String id);
}
