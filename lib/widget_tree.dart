
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    return StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot){
          if(snapshot.hasData){
            User? user = snapshot.data;
            print("has data: ${snapshot.hasData}");
            print("has data: ${user!.email.toString()}");

            if (user != null && !user.emailVerified) {
              return VerifyUserPage();
            } else {
              // Navigate to the home page after successful verification
              return ContainerBar();  // Adjust this based on your app structure
            }
          }else{
            return LoginRegisterPage();
          }
        });
  }
}
