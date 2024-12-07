import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:strive_project/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();


  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future resetPassword() async{
    String email = _emailController.text.trim();
    try{
      await AuthService().resetPassword(email);
      _showSnackBar(context, "Password reset email sent!");
      _emailController.clear();
      Navigator.pop(context);
    }on FirebaseAuthException catch (e){
      print("Error in reset: $e");
      _showSnackBar(context, e.message.toString());

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
  void _showSnackBar(BuildContext context, String message){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black54,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot password"),),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Column(
            children: [
              Text("Enter your email and link will be send to change your password:"),
              _entryField("Enter email", _emailController),
              SizedBox(height: 20,),
              ElevatedButton(
                  onPressed:resetPassword ,
                  child: Text("Send link"))



            ],
          ),
        ),
      ),
    );
  }
}
