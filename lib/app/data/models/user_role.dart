enum UserRole {
  admin,
  user;

  String get label => this == UserRole.admin ? 'Admin' : 'User';
}
