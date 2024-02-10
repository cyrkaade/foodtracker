import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flashcards_quiz/views/scanning_screen.dart';

class GlobalBluetoothDataStream extends StatefulWidget {
  final Widget child;

  const GlobalBluetoothDataStream({Key? key, required this.child}) : super(key: key);

  @override
  _GlobalBluetoothDataStreamState createState() => _GlobalBluetoothDataStreamState();
}

class _GlobalBluetoothDataStreamState extends State<GlobalBluetoothDataStream> {
  StreamSubscription<double>? ppmSubscription;
  StreamSubscription<double>? ammoniaSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for Bluetooth data streams
    ppmSubscription = BluetoothManager.instance.ppmStreamController.stream.listen((ppmValue) {
      // Here, you can handle the PPM value. For example, update a state management solution or directly setState in this widget
      print("PPM Value Updated: $ppmValue");
    });

    ammoniaSubscription = BluetoothManager.instance.ammoniaStreamController.stream.listen((ammoniaValue) {
      // Similarly, handle the ammonia value
      print("Ammonia Value Updated: $ammoniaValue");
    });
  }

  @override
  void dispose() {
    // Cancel subscriptions when not needed to prevent memory leaks
    ppmSubscription?.cancel();
    ammoniaSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}