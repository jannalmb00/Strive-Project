import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//services
import 'package:strive_project/services/index.dart';
//pages
import 'package:strive_project/pages/index.dart';
import 'package:strive_project/widget_tree.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _schoolNameController = TextEditingController();

  Future<void> saveUserDetails() async{
    final User? user = AuthService().currentUser;

    if(user != null){
      try{
        String email = user.email ?? "defaultEmail@example.com";
        await AuthService().addAdditionalUserInfo(user.uid, email, _nameController.text, _schoolNameController.text);
        await AuthService().storeUserEmail(email);

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WidgetTree()));
      }catch(e){
        print("Error saving user details: $e");
      }
    }

  }
  void clearController(){
    _nameController.clear();
    _schoolNameController.clear();
  }
  void _showSnackBar(BuildContext context, String message){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black54,
        )
    );
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter User's data", style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurpleAccent,
        ),),
      ),body: Container(
      padding: EdgeInsets.all(30),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter your details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
            _entryField("Enter your name", _nameController),
            _entryField("Enter schoolname", _schoolNameController),
            SizedBox(height: 20,),
            ElevatedButton(
                onPressed: (){
                  if(_nameController.text.isEmpty && _schoolNameController.text.isEmpty){
                    _showSnackBar(context, "Never leave anything empty");
                    clearController();

                  }else{
                    saveUserDetails();
                  }
                },
                child: Text('Register'))

          ],
        ),
      ),
    ),
    );
  }
}
