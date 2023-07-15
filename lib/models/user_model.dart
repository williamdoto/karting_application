import 'package:flutter/foundation.dart';

class User extends ChangeNotifier {
  final String id;
  final String email;

  User({required this.id, required this.email});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
    );
  }
}
