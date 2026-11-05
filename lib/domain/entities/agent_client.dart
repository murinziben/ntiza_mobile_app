/// A farmer an agent books for — `agentClients/{id}`.
class AgentClient {
  const AgentClient({
    required this.id,
    required this.agentId,
    required this.name,
    required this.phone,
    required this.district,
    this.createdAt,
  });

  final String id;
  final String agentId;
  final String name;
  final String phone;
  final String district;
  final DateTime? createdAt;

  AgentClient copyWith({String? name, String? phone, String? district}) => AgentClient(
        id: id,
        agentId: agentId,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        district: district ?? this.district,
        createdAt: createdAt,
      );
}
