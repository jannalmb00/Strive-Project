import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
//model
import 'package:strive_project/models/index.dart';

class AuthService{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  })async{
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password
    );
  }

  Future<bool> createUser({
    required String email,
    required String password,
    required String name,
    required String schoolName,
  }) async {
    try {
      print('${email}, ${password}, ${name}, ${schoolName}');

      // Create the user with email and password
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user from Firebase Auth
      User? user = userCredential.user;

      if (user != null) {
        print(user.uid.toString());


        return true;
      } else {
        print("User is null");
        return false; // Return false if user is null
      }
    } catch (e) {
      print("Error creating user: $e");
      return false; // Return false if an error occurs
    }
  }

  Future<bool> addAdditionalUserInfo(
      String userId,
      String email,
      String name,
      String schoolName,
      ) async {
    try {
      // Add user data to Firestore
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'schoolName': schoolName,
        'email': email,
      });

      // Print success message
      print('User data added to Firestore successfully');
      return true; // Return true on success
    } catch (e) {
      // Handle error and print error message
      print("Error adding user to Firestore: $e");
      return false; // Return false on error
    }
  }





  Future resetPassword(String email) async{
   try{
     await _firebaseAuth.sendPasswordResetEmail(email: email);
     print('Password reset email sent');
   }on FirebaseAuthException catch (e){
     print('Error sending password reset email: $e');
   }

  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = currentUser;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();  // Sends the verification email
        print('Verification email sent to ${user.email}');
      } else {
        print('User is already verified or not signed in');
      }
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred while sending verification email';
    }
  }

  Future<void> storeUserEmail(String email) async {
    try {
      await FirebaseFirestore.instance.collection('userEmails').add({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(), // Store the registration timestamp
        'streakNumber': 0
      });
    } catch (e) {
      print('Error storing email: $e');
    }
  }

  Future<void> addFriend(String email) async{
    try{
      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid);

      final userDoc = await user.get();
      List<dynamic> listOfFriendsDynamic = userDoc['listOfFriends'] ?? [];

      listOfFriendsDynamic.add(email);

      await user.update({
        'listOfFriends': listOfFriendsDynamic,
      });
    }catch(e){
      print('Error add friends email: $e');
    }
  }

  Future<void> addCurrentUserAsFriend(String membersEmail) async{
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        print('No user is currently logged in.');
        return;
      }
      final String? currentUserEmail = currentUser.email;
      if (currentUserEmail == null) {
        print('Current user email is null.');
        return;
      }

      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: membersEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the member's document
        DocumentSnapshot memberDoc = querySnapshot.docs.first;

        // Get their listOfFriends
        List<dynamic> listOfFriendsDynamic = memberDoc['listOfFriends'] ?? [];

        // Add the current user's email (allow duplicates as per your request)
        listOfFriendsDynamic.add(currentUserEmail);

        // Update the member's document
        await _firestore.collection('users').doc(memberDoc.id).update({
          'listOfFriends': listOfFriendsDynamic,
        });
        print('Successfully added current user as a friend to $membersEmail');
      } else {
        print('No user found with the email $membersEmail');
      }
    }catch (e) {
      print('Error adding current user as friend: $e');
    }
  }

  Future<void> deleteFriend(String email) async{
    try{
      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid);

      final userDoc = await user.get();
      List<dynamic> listOfFriends = userDoc['listOfFriends'] ?? [];

      if (listOfFriends.contains(email)) {
        listOfFriends.remove(email); // Remove the first occurrence
        await user.update({
          'listOfFriends': listOfFriends,
          // Update the list of friends with the modified list
        });
      }
    }catch(e){
      print('Error add friends email: $e');
    }
  }

  Future<void> deleteCurrentUserasFriend() async{
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        print('No user is currently logged in.');
        return;
      }
      final String? currentUserEmail = currentUser.email;
      if (currentUserEmail == null) {
        print('Current user email is null.');
        return;
      }

      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('listOfFriends', arrayContains: currentUserEmail)
          .get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        List<dynamic> friendsList = doc['listOfFriends'] ?? [];

        // Remove the current user's email
        friendsList.remove(currentUserEmail);

        // Update the document with the new friends list
        await doc.reference.update({
          'listOfFriends': friendsList,
        });

        print("Current user's email removed from friends' lists.");
      }
    }catch (e){
      print("Error removing current user as a friend: $e");
    }

  }

  Future<void> signOut() async{
    await _firebaseAuth.signOut();
  }

  //getter method for extra fields
  //getter method for extra fields
  Future<UserModel?> getUserModel() async {
    final User? user = _firebaseAuth.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return UserModel.fromFirestore(userDoc);
    }
    return null;
  }

  Future<List<String>> getListFriends() async{
    final User? user = _firebaseAuth.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if(userDoc.exists){
        List<dynamic> listOfFriendsDynamic = userDoc['listOfFriends'] ?? [];
        List<String> listOfFriends = listOfFriendsDynamic.map((e) => e.toString()).toList();
        List<String> uniqueListOfFriends = listOfFriends.toSet().toList();
        return uniqueListOfFriends;
      }else{
        print("User document doesn't exist");
        return [];
      }

    }else {
      // If no user is logged in
      print("No user is logged in");
      return [];
    }

  }

  Future<String?> getUserName() async {
    UserModel? userModel = await getUserModel();
    return userModel?.name;
  }

  Future<String?> getSchoolName() async {
    UserModel? userModel = await getUserModel();
    return userModel?.schoolName;
  }

  Future<void> save(String name, String age) async{
    try{
      await FirebaseFirestore.instance.collection('mock').add({
        'name': name,
        'age': age
      });

    }catch (e) {
      print('Error storing email: $e');
    }

  }

}