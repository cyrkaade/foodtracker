import 'package:flashcards_quiz/widgets/dotted_lines.dart';
import 'package:flutter/material.dart';

class ResultsCard extends StatelessWidget {
  
  final int ppmValue;
  final int ammoniaValue;
  final double phValue;
  final String whichTopic;
  final Color bgColor3;

  const ResultsCard({
    Key? key,
    required this.ppmValue,
    required this.ammoniaValue,
    required this.phValue,
    required this.whichTopic,
    required this.bgColor3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine freshness based on the topic and ppmValue
    bool isFresh;
    if (whichTopic == "Milk") {
      isFresh = ppmValue < 2000 && phValue > 6.5; // For Milk, check if less than 2000
    } else {
      isFresh = ammoniaValue < 15; // For Beef, Chicken, and Horse, check if less than 15
    }

    // Determine the color based on freshness
    Color scoreColor = isFresh ? Colors.green : Colors.red;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.888,
      height: MediaQuery.of(context).size.height * 0.568,
      child: Stack(
        children: [
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "\n The freshness index is  \n",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            TextSpan(
                              text: "$ppmValue",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    fontSize: 30,
                                    color: scoreColor, // Use dynamic color based on freshness
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  CustomPaint(
                    painter: DrawDottedhorizontalline(),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: isFresh
                            ? Column(
                                children: [
                                  Text(
                                    "This is fresh product",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.w400,
                                        ),
                                  ),
                                  Image.asset("assets/bouncy-cup.gif",
                                      fit: BoxFit.fill,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.25),
                                ],
                              )
                            : Column(
                                children: [
                                  Text(
                                    "This is not fresh product",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Image.asset("assets/sad.png",
                                      fit: BoxFit.fill,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.25),
                                ],
                              ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: -10,
            top: MediaQuery.of(context).size.height * 0.178,
            child: Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(color: bgColor3, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            right: -10,
            top: MediaQuery.of(context).size.height * 0.178,
            child: Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(color: bgColor3, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}
