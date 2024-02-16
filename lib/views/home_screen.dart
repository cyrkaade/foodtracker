import 'package:flashcards_quiz/models/flutter_topics_model.dart';
import 'package:flashcards_quiz/views/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashcards_quiz/views/scanning_screen.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Create StreamSubscriptions to listen to the ppm and ammonia streams
  double ppmValue = 0.0; // Initial ppm value
  double ammoniaValue = 0.0; // Initial ammonia value
  double phValue = 0.0;
  late StreamSubscription<double>? ppmSubscription;
  late StreamSubscription<double>? ammoniaSubscription;
  late StreamSubscription<double> phSubscription;

  @override
  void initState() {
    super.initState();
    // Subscribe to the ppm and ammonia streams from BluetoothManager
    ppmSubscription = BluetoothManager.instance.ppmStreamController.stream.listen(
      (value) {
        setState(() {
          ppmValue = value; // Update ppm value on data arrival
        });
      },
    );

    ammoniaSubscription = BluetoothManager.instance.ammoniaStreamController.stream.listen(
      (value) {
        setState(() {
          ammoniaValue = value; // Update ammonia value on data arrival
        });
      },
    );
    phSubscription = BluetoothManager.instance.phStreamController.stream.listen(
      (value) {
        setState(() {
          phValue = value; // Update pH value on data arrival
        });
      },
    );
  }
  

  @override
  void dispose() {
    // Cancel the subscriptions when the widget is disposed
    ppmSubscription?.cancel();
    ammoniaSubscription?.cancel();
    phSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF4993FA);
    const Color bgColor3 = Color(0xFF5170FD);
    return Scaffold(
      backgroundColor: bgColor3,
      appBar: AppBar(
        backgroundColor: bgColor3,
        elevation: 0,
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
                height: 30,
              ),
              Text(
      'Current ppm Value: $ppmValue',
      style: TextStyle(color: Colors.white, fontSize: 16),
    ),
    const SizedBox(
                height: 10,
              ),
    Text(
      'Current ammonia Value: $ammoniaValue',
      style: TextStyle(color: Colors.white, fontSize: 16),
    ),
    const SizedBox(
                height: 10,
              ),
    Text(
      'Current pH Value: $phValue',
      style: TextStyle(color: Colors.white, fontSize: 16),
    ),
        const SizedBox(
                height: 40,
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
              StreamBuilder<double>(
                stream: BluetoothManager.instance.ppmStreamController.stream,
                builder: (context, snapshot) {
                  return Container(); // Placeholder or loading indicator
                },
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
                    onTap: () async {
                      final String topicName = topicsData.topicName;
                      if (BluetoothManager.instance.isDeviceConnected) {
                      await BluetoothManager.instance.sendMessage("ON");
                    }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoadingWidget(
                            ppmStream: BluetoothManager.instance.ppmStreamController.stream,
                            whichTopic: topicName,
                            ammoniaStream: BluetoothManager.instance.ammoniaStreamController.stream,
                            phStream: BluetoothManager.instance.phStreamController.stream,
                          ),
                        ),
                      );
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




// class HomePage extends StatelessWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     const Color bgColor = Color(0xFF4993FA);
//     const Color bgColor3 = Color(0xFF5170FD);

//     return Scaffold(
//       backgroundColor: bgColor3,
//       appBar: AppBar(
//         backgroundColor: bgColor3,
//         elevation: 0,
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(Icons.bluetooth),
//             onPressed: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(builder: (context) => BluetoothDevicesScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.only(top: 0, left: 15, right: 15),
//           child: ListView(
//             physics: const BouncingScrollPhysics(),
//             children: [
//               // Other widgets remain unchanged
              
//               // For demonstration, let's assume you're interested in showing a list of topics
//               // and passing the latest PPM value to LoadingWidget when a topic is selected.
//               StreamBuilder<double>(
//                 stream: BluetoothManager.instance.ppmStreamController.stream,
//                 builder: (context, snapshot) {
//                   // Check if we have a valid PPM value
//                   double latestPpmValue = snapshot.data ?? 0.0; // Default to 0 or handle appropriately

//                   // Your GridView.builder or any widget that needs the PPM value
//                   return GridView.builder(
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       mainAxisSpacing: 10,
//                       crossAxisSpacing: 10,
//                       childAspectRatio: 0.85,
//                     ),
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(), // Fix scrolling issues within ListView
//                     itemCount: flutterTopicsList.length,
//                     itemBuilder: (context, index) {
//                       final topicsData = flutterTopicsList[index];
//                       return GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => LoadingWidget(
//                                 ppmStream: BluetoothManager.instance.ppmStreamController.stream,
//                                 whichTopic: topicsData.topicName,
//                                 ammoniaStream: BluetoothManager.instance.ammoniaStreamController.stream,
//                                 latestPpmValue: latestPpmValue, // Pass the latest PPM value
//                               ),
//                             ),
//                           );
//                         },
//                         // Your Card widget remains unchanged
//                       );
//                     },
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
