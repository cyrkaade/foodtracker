// // bluetooth_devices_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flashcards_quiz/views/connection.dart'; // Ensure this is the correct path

// class BluetoothDevicesScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Select Device'),
//       ),
//       body: SelectBondedDevicePage(
//         onCahtPage: (device) {
//           // You can navigate to a different page here after connecting to a device
//           // For example, if you have a chat page or device control page
//           Navigator.pop(context); // This goes back after selecting a device, you might want to navigate elsewhere
//         },
//       ),
//     );
//   }
// }
