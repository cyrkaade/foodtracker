import 'package:flashcards_quiz/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flashcards_quiz/views/scanning_screen.dart';
import 'package:flashcards_quiz/widgets/gbdl.dart';

void main() {
  runApp(
    GlobalBluetoothDataStream(child: MyApp()),
  );
  BluetoothManager.instance;
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Get the device and select the type of product',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
        fontFamily: "Montserrat",
      ),
      home: const HomePage(),
    );
  }
}
