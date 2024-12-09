import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strive_project/models/group_model.dart';
import 'package:strive_project/services/auth_service.dart';
import 'dart:math';


class GroupService{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  AuthService authService = AuthService();
  Random random = Random();

  Future<int?> checkUserEmail(String email) async{
    try{
      //
      var userFind = await FirebaseFirestore.instance
                              .collection('userEmails')
                              .where('email', isEqualTo: email)
                              .get();

       if(userFind.docs.isNotEmpty){
         var streakNumber = userFind.docs.first.data()['streakNumber'];

         if (streakNumber is int) {
           return streakNumber;
         } else if (streakNumber is String) {
           return int.tryParse(streakNumber) ?? 0; // Handle String as int
         }
      }
      return null;

    } catch (e){
      print('Error checking email: $e');
      return null;
      }
    }

  Future<bool> createGroup(String groupName, String description,String groupFileName,String ownerEmail, List<String> members) async {
    try {
      if (currentUser == null) {
        return false; // User not signed in
      }

      // Fetch the user's groups
      List<Map<String, dynamic>> userGroups = await fetchUserGroups(currentUser!.email!);

      bool isDuplicateGroup = userGroups.any((group) => group['groupName'] == groupName);

      if (isDuplicateGroup) {
        return false; // Duplicate group name
      }

      int randomInt = random.nextInt(100);

      String customGroupId = '${currentUser!.email}-${groupName.replaceAll(' ', '-')}.${randomInt.toString()}';
      
      GroupModel newGroup = GroupModel(groupID: customGroupId, groupName: groupName, groupDescription: description, groupFileName: groupFileName,ownerEmail: ownerEmail, members: members);

      // Create the group with a custom ID
      await _firestore.collection('groups').doc(customGroupId).set(newGroup.toMap());

      return true; // Group created successfully
    } catch (e) {
      print('Error creating group: $e');
      return false;
    }
  }

  Future<void> deleteGroup(String groupID) async {
    try {
      AuthService().deleteCurrentUserasFriend();
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupID)
          .delete();
    } catch (e) {
      print("Error deleting task: $e");
    }
  }
  
  Future<bool> editGroup(GroupModel group) async {

    try{
      await _firestore.collection('groups')
          .doc(group.groupID)
          .update(group.toMap());
      return true;

    }catch(e){
      print("Error editing group: $e");
      return false;
    }

  }

  Future<List<Map<String, dynamic>>> fetchUserGroups(String userEmail) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where('members', arrayContains: userEmail) // Filter by email in members array
          .get();

      List<Map<String, dynamic>> groups = [];
      for (var doc in querySnapshot.docs) {
        groups.add(doc.data());
      }

      return groups; // Return list of groups
    } catch (e) {
      print("Error fetching groups: $e");
      return [];
    }
  }



  }



