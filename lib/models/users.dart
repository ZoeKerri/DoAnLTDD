class User {
  final int? id;
  final String name;
  final String email;
  final String password;

  User({this.id, required this.name, required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
    );
  }

  // Dành cho Firebase: Chuyển đổi đối tượng User sang Map
  Map<String, dynamic> toFirebaseMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }

  // Dành cho Firebase: Tạo đối tượng User từ Map
  factory User.fromFirebaseMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'] ?? '', 
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }
}