import '../../core/errors/app_exception.dart';
import '../entities/agent_client.dart';
import '../repositories/admin_repository.dart';
import '../validators.dart';

/// Rules for the farmers an agent books for.
class AgentUseCases {
  AgentUseCases(this._agents);

  final AgentRepository _agents;

  /// Creates the client when [AgentClient.id] is empty, otherwise updates it.
  Future<void> saveClient(AgentClient client) async {
    final error = Validators.fullName(client.name) ??
        Validators.phone(client.phone) ??
        Validators.district(client.district);
    if (error != null) throw AppException(error);
    final cleaned = client.copyWith(phone: normalizePhone(client.phone), name: client.name.trim());
    if (cleaned.id.isEmpty) {
      await _agents.addClient(cleaned);
    } else {
      await _agents.updateClient(cleaned);
    }
  }

  Future<void> deleteClient(String id) => _agents.deleteClient(id);
}
