
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strive_project/pages/splash_screen.dart';
//srvice
import 'package:strive_project/services/index.dart';
//page
import 'package:strive_project/pages/index.dart';
//model
import 'models/index.dart';


class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot){
          if(snapshot.hasData){
            User? user = snapshot.data;
            print("has data: ${snapshot.hasData}");
            print("has data: ${user!.email.toString()}");


            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5), // Semi-transparent background
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Custom color
                        strokeWidth: 4.0, // Adjust stroke width
                      ),
                    ),
                  );
                }

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  return SplashScreen(); // Main app screen if user data exists
                } else {
                  return UserDetailsPage(); // Prompt for additional details if no data exists
                }
              },
            );
          }else{
            return LoginRegisterPage();
          }
        });
  }

  Future<Widget> _checkUserData(User? user) async {
    if (user != null) {
      // Check if the user has additional data stored in Firestore
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        return SplashScreen();  // Main content screen if user data exists
      } else {
        return UserDetailsPage();  // Page to collect additional user details
      }
    } else {
      return LoginRegisterPage();
    }
  }
}
