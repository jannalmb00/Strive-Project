import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
//import 'package:strive_project/services/theme_service.dart';

//model
import 'package:strive_project/models/index.dart';

//service
import 'package:strive_project/services/index.dart';

//page
import 'package:strive_project/pages/index.dart';

import 'package:strive_project/widget_tree.dart';

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

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WidgetTree()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueGrey,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: 'Light',
                    items: <String>['Light', 'Dark']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        Provider.of<ThemeService>(context, listen: false)
                            .setTheme(newValue);
                      }
                    },
                  )
          ],
        ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue, size: 30),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${userName ?? 'Guest'}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.school, color: Colors.blue, size: 30),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${schoolName ?? 'Not entered'}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.email, color: Colors.blue, size: 30),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        user?.email ?? 'User email',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: signOut,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: Text("Sign Out", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
