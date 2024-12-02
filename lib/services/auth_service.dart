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

  Future<void> createUser({
    required String email,
    required String password,
    required String name,
    required String schoolName,
  }) async{
    try {

      print('${email}, ${password}, ${name}, ${schoolName}');
      // Create the user with email and password
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user from Firebase Auth
      User? user = userCredential.user;

      print(user!.uid.toString());
      // Store additional user data in Firestore
      if (user != null) {
        storeUserEmail(email);
        // Attempt to add user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'schoolName': schoolName,
          'email': email,
        }).then((value) {
          print('User data added to Firestore successfully');
        }).catchError((error) {
          print('Error storing user data in Firestore: $error');
        });

       // await _firebaseAuth.signOut();
      }else{
        print("user is null right? ");

      }

    } catch (e) {
      print("Error creating user: $e");
    }
  }

  // Future<void> sendVerificationEmail() async {
  //   try {
  //     final user = currentUser;
  //
  //     if (user != null && !user.emailVerified) {
  //       await user.sendEmailVerification();  // Sends the verification email
  //       print('Verification email sent to ${user.email}');
  //     } else {
  //       print('User is already verified or not signed in');
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     throw e.message ?? 'An error occurred while sending verification email';
  //   }
  // }

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

      await user.update({
        'listOfFriends': FieldValue.arrayUnion([email]),
      });
    }catch(e){
      print('Error add friends email: $e');
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
        return listOfFriends;
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
}