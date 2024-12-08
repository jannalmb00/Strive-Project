import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//model
import 'package:strive_project/models/index.dart';

//service
import 'package:strive_project/services/index.dart';

//page
import 'package:strive_project/pages/index.dart';

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
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();

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

  Widget _entryField(String title, TextEditingController controller,  {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginRegisterPage()));
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
            SizedBox(height: 10,),

          ],
        ),
      ),
    );
  }
}
