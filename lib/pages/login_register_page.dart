import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:strive_project/pages/forgot_password_page.dart';
//service
import 'package:strive_project/services/index.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  String errorMessage = '';
  bool isLogin = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await AuthService().signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'An unknown error occurred';
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      print(_nameController.text);
      bool authnCreate = await AuthService().createUser(  // Corrected typo here
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          schoolName: _schoolNameController.text
      );

      if(authnCreate){
        String id = AuthService().currentUser!.uid;
       // _showSnackBar(context, id);
        //await AuthService().addAdditionalUserInfo(id, _emailController.text, _nameController.text, _schoolNameController.text);

      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'An unknown error occurred';
      });
    }
  }

  // Widgets
  Widget _title() {
    return const Text('Firebase Auth');
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

  Widget _errorMessage() {
    return Text(errorMessage.isEmpty ? '' : 'Hmm? $errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      child: Text(isLogin ? 'Login' : 'Register'),
    );  // Added missing semicolon
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(isLogin ? 'Register instead' : 'Login instead'),
    );
  }
  Widget _forgotpasswordButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return ForgotPasswordPage();
        }));
      },
      child: Text('Forgot password',
      style: TextStyle(
        color: Colors.indigoAccent,
        fontWeight: FontWeight.bold
      ),),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!isLogin) _entryField('Name', _nameController),
            if(!isLogin) _entryField('School Name:', _schoolNameController),
            _entryField('Email', _emailController),
            _entryField('Password', _passwordController,isPassword: true),
            _errorMessage(),
            _submitButton(),
            _loginOrRegisterButton(),
            _forgotpasswordButton()

          ],
        ),
      ),
    );
  }
}
