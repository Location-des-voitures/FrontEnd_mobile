

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final bool emailVerified;
  final String createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.emailVerified,
    required this.createdAt,
  });

 
  bool get isAdmin      => role == 'admin';
  bool get isClient     => role == 'client';
  bool get isSuperAdmin => role == 'super_admin';
  bool get canLogin     => isActive && emailVerified;

  @override
bool operator ==(Object other) =>
    identical(this, other) ||
    other is User && runtimeType == other.runtimeType && id == other.id;

@override
int get hashCode => id.hashCode;

}