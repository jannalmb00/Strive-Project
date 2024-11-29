import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String email;
  String password;
  String? name;
  String? schoolName;

  // Constructor
  UserModel({
    required this.email,
    required this.password,
    this.name,
    this.schoolName,
  });

  // Convert UserModel to Map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'schoolName': schoolName,
    };
  }

  // Create a UserModel from a Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] as String,
      password: map['password'] as String,
      name: map['name'] as String?,
      schoolName: map['schoolName'] as String?,
    );
  }

  // Convert a Firestore document to a UserModel object
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      name: data['name'],
      schoolName: data['schoolName'],
    );
  }
}
