import 'package:flutter/foundation.dart';

class User extends ChangeNotifier {
  final String id;

  User({required this.id});

  Map<String, dynamic> toMap() {
    return {'id': id};
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
    );
  }
}
