import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flashcards_quiz/views/results_screen.dart';

class LoadingWidget extends StatefulWidget {
  final Stream<double> ppmStream;
  final String whichTopic;
  const LoadingWidget({Key? key, required this.ppmStream, required this.whichTopic}) : super(key: key); // Modify this line

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  double latestPpmValue = 0.0;

@override
void initState() {
    super.initState();
    widget.ppmStream.listen((value) {
      latestPpmValue = value;
    });
    // Delay and then navigate to ResultsScreen
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            score: latestPpmValue,
            totalQuestions: 0,
            whichTopic: widget.whichTopic, // Use the passed whichTopic here
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/loading.json',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(
              'Checking... Please, wait a second.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
