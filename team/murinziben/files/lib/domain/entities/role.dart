/// The five kinds of account in NTIZA.
enum Role { farmer, owner, expert, agent, admin }

extension RoleX on Role {
  String get label => switch (this) {
        Role.farmer => 'Farmer',
        Role.owner => 'Equipment Owner',
        Role.expert => 'Agricultural Expert',
        Role.agent => 'Booking Agent',
        Role.admin => 'Admin',
      };

  /// The root route of this role's area of the app.
  String get home => switch (this) {
        Role.farmer => '/farmer',
        Role.owner => '/owner',
        Role.expert => '/expert',
        Role.agent => '/agent',
        Role.admin => '/admin',
      };

  /// Partner roles must be approved by an admin before they can use the app.
  bool get needsApproval => this != Role.farmer && this != Role.admin;
}

Role roleFromName(String? name) =>
    Role.values.firstWhere((r) => r.name == name, orElse: () => Role.farmer);
