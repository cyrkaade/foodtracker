import 'package:flashcards_quiz/models/flutter_topics_model.dart';
import 'package:flashcards_quiz/views/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashcards_quiz/views/scanning_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF4993FA);
    const Color bgColor3 = Color(0xFF5170FD);
    return Scaffold(
      backgroundColor: bgColor3,
      appBar: AppBar(
        backgroundColor: bgColor3, // Use the same background color for the app bar
        elevation: 0, // Remove shadow
        actions: <Widget>[
          IconButton(
          icon: Icon(Icons.bluetooth),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => BluetoothDevicesScreen()),
            );
          },
        ),

        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 0, left: 15, right: 15),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: bgColor3,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.24),
                      blurRadius: 20.0,
                      offset: const Offset(0.0, 10.0),
                      spreadRadius: -10,
                      blurStyle: BlurStyle.outer,
                    )
                  ],
                ),
                child: Image.asset("assets/dash.png"),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Get the device and select the type of product: ",
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontSize: 21,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                      ),
                      // for (var i = 0; i < "Riddles!!!".length; i++) ...[
                      //   TextSpan(
                      //     text: "Riddles!!!"[i],
                      //     style: Theme.of(context)
                      //         .textTheme
                      //         .headlineSmall!
                      //         .copyWith(
                      //           fontSize: 21 + i.toDouble(),
                      //           color: Colors.white,
                      //           fontWeight: FontWeight.w400,
                      //         ),
                      //   ),
                      // ]
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: flutterTopicsList.length,
                itemBuilder: (context, index) {
                  final topicsData = flutterTopicsList[index];
                  return GestureDetector(
                  onTap: () {
                      final String topicName = flutterTopicsList[index].topicName; 
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoadingWidget(
                            ppmStream: BluetoothManager.instance.ppmStreamController.stream,
                            whichTopic: topicName,
                          ),
                        ),
                      );
                      print(topicName);
                    },
                    child: Card(
                      color: bgColor,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image(
                              image: topicsData.topicIcon.image, // Use the image property of the Image widget
                              color: Colors.white,
                              width: 65,
                              height: 65,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              topicsData.topicName,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                  ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
