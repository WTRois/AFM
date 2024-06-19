class User {
  final int id;
  final String nama;
  final String email;
  final String? foto_user;

  const User({
    required this.id,
    required this.nama,
    required this.email,
    this.foto_user
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nama: json['nama'],
      email: json['email'],
      foto_user: json['foto_user'],
    );
  }
}