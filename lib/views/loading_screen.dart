import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flashcards_quiz/views/results_screen.dart';

class LoadingWidget extends StatefulWidget {
  final Stream<double> ppmStream;
  final Stream<double> ammoniaStream;
  final String whichTopic;
  final Stream<double> phStream;

  const LoadingWidget({
    Key? key, 
    required this.ppmStream, 
    required this.ammoniaStream, 
    required this.whichTopic,
    required this.phStream,
  }) : super(key: key);

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  double latestPpmValue = 0.0;
  double latestPhValue = 0.0;
  double latestAmmoniaValue = 0.0;

  late final StreamSubscription<double> _ppmSubscription;
  late final StreamSubscription<double> _phSubscription;
  late final StreamSubscription<double> _ammoniaSubscription;

  @override
  void initState() {
    super.initState();
    _ppmSubscription = widget.ppmStream.listen((value) => updateValue(value, 'ppm'));
    _ammoniaSubscription = widget.ammoniaStream.listen((value) => updateValue(value, 'ammonia'));
    _phSubscription = widget.phStream.listen((value) => updateValue(value, 'ph'));

    Future.delayed(Duration(seconds: 30), navigateToResults);
  }

  void updateValue(double value, String type) {
    if (mounted) {
      setState(() {
        if (type == 'ppm') latestPpmValue = value;
        else if (type == 'ammonia') latestAmmoniaValue = value;
        else if (type == 'ph') latestPhValue = value;
      });
    }
  }

  void navigateToResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          ppmValue: latestPpmValue,
          ammoniaValue: latestAmmoniaValue,
          phValue: latestPhValue,
          whichTopic: widget.whichTopic,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ppmSubscription.cancel();
    _ammoniaSubscription.cancel();
    _phSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine which text to display based on whichTopic
    String displayText;
    if (widget.whichTopic == "Milk") {
      displayText = 'PH: ${latestPhValue.toStringAsFixed(2)}\n'
                     'PPM: ${latestPpmValue.toStringAsFixed(2)}';
    } else {
      displayText = 'Ammonia: ${latestAmmoniaValue.toStringAsFixed(2)}';
    }

    return Scaffold(
      body: Stack(
        children: [
          Center(
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
          Positioned(
            right: 10,
            bottom: 10,
            child: Text(
              displayText,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
