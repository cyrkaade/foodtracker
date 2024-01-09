import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/loading.json', // Replace with your actual file path
          width: 200, // Adjust width as needed
          height: 200, // Adjust height as needed
          fit: BoxFit.cover, // Adjust the fit as needed
        ),
      ),
    );
  }
}
