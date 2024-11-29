import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//model
import 'package:strive_project/models/index.dart';

//service
import 'package:strive_project/services/index.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final User? user = AuthService().currentUser;
  String? userName;
  String? schoolName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      try {
        // Fetch both user name and school name together
        UserModel? userModel = await AuthService().getUserModel();
        setState(() {
          userName = userModel?.name ?? 'Guest';
          schoolName = userModel?.schoolName ?? 'Not entered';
          isLoading = false;
        });
      } catch (e) {
        _showSnackBar(context, 'Error fetching user data: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        userName = 'Guest';
        schoolName = 'Not entered';
        isLoading = false;
      });
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black54,
      ),
    );
  }

  Future<void> signOut() async {
    await AuthService().signOut();
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login on sign out
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Name: ${userName ?? 'Guest'}'),
            Text('School name: ${schoolName ?? 'Not entered'}'),
            Text(user?.email ?? 'User email'),
            ElevatedButton(
              onPressed: signOut,
              child: Text("Signout"),
            ),
          ],
        ),
      ),
    );
  }
}
