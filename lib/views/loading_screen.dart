import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flashcards_quiz/views/results_screen.dart';

class LoadingWidget extends StatefulWidget {
  final Stream<double> ppmStream;
  final Stream<double> ammoniaStream;
  final String whichTopic;

  const LoadingWidget({
    Key? key, 
    required this.ppmStream, 
    required this.ammoniaStream, 
    required this.whichTopic,
  }) : super(key: key);

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  double latestValue = 0.0;

  @override
  void initState() {
    super.initState();
    // Listen to the appropriate stream based on `whichTopic`
    Stream<double> relevantStream = widget.whichTopic == "Milk" ? widget.ammoniaStream : widget.ppmStream;
    relevantStream.listen((value) {
      setState(() {
        latestValue = value;
      });
    });
    // Delay and then navigate to ResultsScreen
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            score: latestValue,
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
