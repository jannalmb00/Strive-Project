import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:strive_project/pages/container_nav_bar.dart';
import 'package:strive_project/pages/user_details_page.dart';
import 'package:strive_project/services/index.dart';
import 'dart:async';

class VerifyUserPage extends StatefulWidget {
  const VerifyUserPage({super.key});

  @override
  State<VerifyUserPage> createState() => _VerifyUserPageState();
}

class _VerifyUserPageState extends State<VerifyUserPage> {
  bool isUserVerified = false;
  Timer? timer;
  bool canResendEmail = false;

  @override
  void initState() {
    super.initState();

    // Check the initial email verification status after widget is built
    checkInitialVerification();
  }

  // Separate method to handle the email verification check asynchronously
  Future<void> checkInitialVerification() async {
    // Wait until Firebase instance is fully loaded
    await FirebaseAuth.instance.currentUser!.reload();
    bool isVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (isVerified) {
      // Navigate immediately if verified
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserDetailsPage()),
      );
    } else {
      setState(() {
        isUserVerified = false;
      });

      // Send the verification email and periodically check verification
      sendVerificationEmail();
      timer = Timer.periodic(
        const Duration(seconds: 3),
            (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    timer?.cancel();
    super.dispose();
  }

  // Check if the email is verified and navigate if verified
  Future<void> checkEmailVerified() async {
    try {
      await FirebaseAuth.instance.currentUser!.reload();
      User? user = FirebaseAuth.instance.currentUser;
      final isVerified = user?.emailVerified ?? false;
      print("is verified: $isVerified");

      if (isVerified) {
        setState(() {
          isUserVerified = true;
        });
        timer?.cancel(); // Cancel the timer

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  ContainerBar()),
        );
      }
    } catch (e) {
      print('Error checking email verification: $e');
    }
  }

  // Send the verification email and allow resending after delay
  Future<void> sendVerificationEmail() async {
    try {
      await AuthService().sendVerificationEmail();
      setState(() => canResendEmail = false);

      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      print('Error sending verification email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isUserVerified
        ?  ContainerBar()
        : Scaffold(
      appBar: AppBar(
        title: const Text('Verify User'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Check your email to verify user"),
            ElevatedButton.icon(
              onPressed: canResendEmail ? sendVerificationEmail : null,
              label: const Text('Resend Email'),
              icon: const Icon(Icons.email),
            ),
            ElevatedButton(
              onPressed: checkEmailVerified,
              child: const Text('Check Email Verification'),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            Text(isUserVerified.toString()),
          ],
        ),
      ),
    );
  }
}
