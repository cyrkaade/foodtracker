import 'package:flashcards_quiz/widgets/results_card.dart';
import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  final double ppmValue;
  final double ammoniaValue; // Added for ammonia
  final double phValue;
  final String whichTopic;

  const ResultsScreen({
    super.key,
    required this.ppmValue,
    required this.ammoniaValue, // Include ammonia in constructor
    required this.phValue,
    required this.whichTopic,
  });

  @override
  Widget build(BuildContext context) {
    const Color bgColor3 = Color(0xFF5170FD);
    // final double percentageScore = totalQuestions != 0 ? (score / totalQuestions) * 100 : 0.0;
    final int roundedppmValue = ppmValue.round();
    final int roundedammoniaValue = ammoniaValue.round();
    final double roundedphValue = phValue;

    const Color cardColor = Color(0xFF4993FA);
    return WillPopScope(
      onWillPop: () {
        Navigator.popUntil(context, (route) => route.isFirst);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: bgColor3,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: bgColor3,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Results On Your food:",
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
              ),
              ResultsCard(
                        ppmValue: roundedppmValue,
                        ammoniaValue: roundedammoniaValue, // Pass ammonia
                        phValue: roundedphValue,
                        whichTopic: whichTopic,
                        bgColor3: cardColor,
                      ),
              const SizedBox(
                height: 25,
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(cardColor),
                  fixedSize: MaterialStateProperty.all(
                    Size(MediaQuery.sizeOf(context).width * 0.80, 40),
                  ),
                  elevation: MaterialStateProperty.all(4),
                ),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text(
                  "Make another check",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
