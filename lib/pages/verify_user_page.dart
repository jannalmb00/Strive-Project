// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:strive_project/pages/container_nav_bar.dart';
// import 'package:strive_project/pages/home_page.dart';
// import 'package:strive_project/services/index.dart';
// import 'dart:async';
//
// class VerifyUserPage extends StatefulWidget {
//   const VerifyUserPage({super.key});
//
//   @override
//   State<VerifyUserPage> createState() => _VerifyUserPageState();
// }
//
// class _VerifyUserPageState extends State<VerifyUserPage> {
//   bool isUserVerified = false;
//   Timer? timer;
//   bool canResendEmail = false;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     isUserVerified = FirebaseAuth.instance.currentUser!.emailVerified;
//
//     if(!isUserVerified){
//       sendVerificationEmail();
//
//       timer = Timer.periodic(
//         Duration(seconds: 3),
//           (_) => checkEmailVerified(),
//       );
//     }
//   }
//
//
//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//
//   }
//
//   Future checkEmailVerified() async{
//     await FirebaseAuth.instance.currentUser!.reload();
//     setState(() {
//       isUserVerified = FirebaseAuth.instance.currentUser!.emailVerified;
//     });
//
//     if(isUserVerified) timer?.cancel();
//   }
//
//   Future sendVerificationEmail() async{
//     try {
//       await AuthService().sendVerificationEmail();  //auth
//       setState(() => canResendEmail = false);
//       await Future.delayed(Duration(seconds: 5));
//       setState(() => canResendEmail = true);
//     } catch (e) {
//
//       print('Error sending verification email: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return isUserVerified
//         ?  ContainerBar()
//         : Scaffold(
//       appBar: AppBar(
//         title: const Text('Verify User'),
//       ),
//       body: Center(
//         child: Column(
//           children: [
//             Text("Check your email to verify user"),
//             ElevatedButton.icon(
//                 onPressed: canResendEmail ? sendVerificationEmail : null,
//                 label: Text('Resend Email'),
//                 icon: Icon(Icons.email),
//             ),
//             TextButton(
//                 onPressed: FirebaseAuth.instance.signOut,
//                 child: Text("Cancel"))
//           ],
//         ),
//
//       ),
//     );
//   }
// }
