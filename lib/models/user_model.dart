import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String email;
  String? name;
  String? schoolName;
  final List<String>? listOfFriends = [];

  // Constructor
  UserModel({
    required this.email,
    this.name,
    this.schoolName,
  });

  // Convert UserModel to Map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'schoolName': schoolName,
      'listOfFriends': listOfFriends
    };
  }

  // Create a UserModel from a Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] as String,
      name: map['name'] as String?,
      schoolName: map['schoolName'] as String?,

    );
  }

  // Convert a Firestore document to a UserModel object
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      email: data['email'] ?? '',
      name: data['name'],
      schoolName: data['schoolName'],

    );
  }
}
