import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupService{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;


  Future<bool> checkUserEmail(String email) async{
    try{
      //
      var userFind = await FirebaseFirestore.instance
                              .collection('userEmails')
                              .where('email', isEqualTo: email)
                              .get();

      return userFind.docs.isNotEmpty;

    } catch (e){
      print('Error checking email: $e');
      return false;
      }
    }

  Future<bool> createGroup(String groupName, String description,String groupFileName, List<String> members) async {
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


      String customGroupId = '${currentUser!.email}-${groupName.replaceAll(' ', '-')}';

      // Create the group with a custom ID
      await _firestore.collection('groups').doc(customGroupId).set({
        'groupID': customGroupId,
        'groupName': groupName,
        'groupDescription': description,
        'groupFileName': groupFileName,
        'members': members,
        'createdBy': currentUser!.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true; // Group created successfully
    } catch (e) {
      print('Error creating group: $e');
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



