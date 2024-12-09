import 'package:flutter/material.dart';
import 'dart:async';

//page
import 'package:raeestrivetwo/pages/index.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ContainerBar()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/flaticon_bird_flying.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10),
            Text("Strive",
                style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20)
            ),
            Text("To be 1% Better Everyday",
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 15)
            ),
          ],
        ),
      ),
    );
  }
}
