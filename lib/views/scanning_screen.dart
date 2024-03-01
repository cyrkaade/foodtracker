import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert'; 
import 'package:rxdart/rxdart.dart';

class BluetoothDevicesScreen extends StatefulWidget {
  @override
  _BluetoothDevicesScreenState createState() => _BluetoothDevicesScreenState();
}

class _BluetoothDevicesScreenState extends State<BluetoothDevicesScreen> {
  TextEditingController textEditingController = TextEditingController();
  StreamController<String> streamController = StreamController.broadcast();
  List<String> messages = [];
  List<BluetoothDevice> devices = [];
  BluetoothConnection? connection;
  bool isConnecting = false;
  bool isDiscovering = false; // Add a new boolean to track discovery status
  // Add a variable to store the PPM value
  double ppmValue = 0.0;
  double ph = 0.0;
  int dataTypeCounter = 0;

  

  @override
  void initState() {
    super.initState();
    requestPermissions(); // Call this at the start
    _getBondedDevices();
    _discoverDevices();
  }
  Future<void> requestPermissions() async {
    // This method requests all necessary permissions when the app starts
    await [Permission.bluetoothScan, Permission.bluetoothConnect, Permission.location].request();
    // You can add more permission checks here if needed
  }

  void _getBondedDevices() async {
    List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      devices = bondedDevices;
    });
  }

void _sendMessage(String text) async {
  if (connection != null && connection!.isConnected) {
    connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n"))); // Send text to Bluetooth device
    await connection!.output.allSent;
    textEditingController.clear(); // Clear the text field
  }
}

void reconnectToDevice() async {
  if (connectedDeviceAddress != null) {
    try {
      final BluetoothConnection newConnection = await BluetoothConnection.toAddress(connectedDeviceAddress!);
      setState(() {
        connection = newConnection;
        // Update UI or state as necessary
      });
      // Set up the listener for the new connection as before
    } catch (e) {
      print('Error reconnecting to device: $e');
      setState(() {
        // Handle error state
      });
    }
  }
}

void _discoverDevices() async {
  // Request necessary permissions at runtime. Adjust according to your needs.
Map<Permission, PermissionStatus> statuses = await [
  Permission.bluetoothScan,
  Permission.bluetoothConnect,
  Permission.location, // Add this line
].request();

  // Check if permissions are granted
  final allPermissionsGranted = statuses.values.every((status) => status.isGranted);
  if (!allPermissionsGranted) {
    print("Necessary Bluetooth permissions not granted");
    return;
  }

  setState(() {
    isDiscovering = true;
  });

  FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
    setState(() {
      final existingIndex = devices.indexWhere((device) => device.address == r.device.address);
      if (existingIndex >= 0) {
        devices[existingIndex] = r.device;
      } else {
        devices.add(r.device);
      }
    });
  }).onDone(() {
    setState(() {
      isDiscovering = false;
    });
  });
}


Future<void> _connect(BluetoothDevice device) async {
  // Simplified connection method with permission checks

  // Update UI based on connection status

  if (await Permission.bluetoothConnect.request().isGranted) {
    try {
      final BluetoothConnection connection = await BluetoothConnection.toAddress(device.address);
      print('Connected to the device');

      setState(() {
      this.connection = connection;
      BluetoothManager.instance.connection = connection; // Update the central manager
      BluetoothManager.instance.isConnected.add(true); // Notify listeners of the connection
      this.connectedDeviceAddress = device.address; // Store connected device address
      isConnecting = false;
    });

      // Listen to data coming from Bluetooth
connection.input?.listen((Uint8List data) {
  String dataStr = utf8.decode(data).trim();
  if (dataStr.startsWith("PPM:")) {
    final value = double.tryParse(dataStr.substring(4)) ?? 0.0;
    BluetoothManager.instance.ppmStreamController.add(value);
  } else if (dataStr.startsWith("AMM:")) {
    final value = double.tryParse(dataStr.substring(4)) ?? 0.0;
    BluetoothManager.instance.ammoniaStreamController.add(value);
  } else if (dataStr.startsWith("PH:")) {
    final value = double.tryParse(dataStr.substring(3)) ?? 0.0;
    BluetoothManager.instance.phStreamController.add(value);
  }
}).onDone(() {
  if (this.mounted) {
    setState(() {
      this.connectedDeviceAddress = null; // Clear connected device address on disconnection
    });
  }
});


    } catch (e) {
      print('Cannot connect, exception occurred');
      print(e);
      if (this.mounted) { // Check if the widget is still in the widget tree
        setState(() {
          isConnecting = false;
          BluetoothManager.instance.isConnected.add(false);
        });
      }
    }
  } else {
    print('Bluetooth connect permission denied');
  }
}

  bool get isConnected => connection?.isConnected ?? false;
  String? connectedDeviceAddress;


@override
void dispose() {
  streamController.close();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      // Send "OFF" message when trying to go back
      if (BluetoothManager.instance.isDeviceConnected) {
        await BluetoothManager.instance.sendMessage("OFF");
      }
      return true; // Allow the user to leave the screen
    },
    child: Scaffold( // Ensure Scaffold is inside the child property of WillPopScope
      appBar: AppBar(
        title: Text("Select a Bluetooth Device"),
        actions: <Widget>[
          // Your refresh button logic here
        ],
      ),
    body: Column(
      children: [
        Expanded(
          child: ListView.builder(
          itemCount: devices.length,
            itemBuilder: (context, index) {
              BluetoothDevice device = devices[index];
              return StreamBuilder<bool>(
                stream: BluetoothManager.instance.isConnected.stream,
                builder: (context, snapshot) {
                  bool isConnected = snapshot.data ?? false;
                  // Check against the stored connectedDeviceAddress
                  bool deviceIsConnected = isConnected && BluetoothManager.instance.connectedDeviceAddress == device.address;
                  return ListTile(
                    leading: Icon(Icons.bluetooth),
                    title: Text(device.name ?? "Unknown Device"),
                    subtitle: Text(device.address),
                    trailing: Text(deviceIsConnected ? "Connected" : "Not connected"),
                    onTap: deviceIsConnected ? null : () => _connect(device),
                  );
                },
                  );
                },
              ),
        ),

        // Dynamically show the message field if a device is connected
        StreamBuilder<bool>(
          stream: BluetoothManager.instance.isConnected.stream,
          builder: (context, snapshot) {
            bool isConnected = snapshot.data ?? false;
            if (isConnected) {
              return Column(
                children: [
                  TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      labelText: "Send a message",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () => _sendMessage(textEditingController.text),
                      )
                      ),
                  ),
                  StreamBuilder<String>(
                    stream: streamController.stream,
                    builder: (context, snapshot) {
                      return Text(snapshot.hasData ? snapshot.data! : "");
                    },
                  ),
                ],
              );
            } else {
              return Container(); // Return an empty container if not connected
            }
          },
        ),
      ],
    ),
    )
  );
}
}

class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._internal();
  
  BluetoothConnection? connection;
  BehaviorSubject<double> ppmStreamController = BehaviorSubject<double>();
  BehaviorSubject<double> ammoniaStreamController = BehaviorSubject<double>();
  BehaviorSubject<double> phStreamController = BehaviorSubject<double>();
  BehaviorSubject<bool> isConnected = BehaviorSubject.seeded(false);
  
  String? connectedDeviceAddress; 
  double ppmValue = 0.0;
  double ammonia = 0.0;
  double ph = 0.0;
  
  // Use two StreamControllers to separately stream ppmValue and ammonia values
  // StreamController<double> ppmStreamController = StreamController.broadcast();
  // StreamController<double> ammoniaStreamController = StreamController.broadcast();

  BluetoothManager._internal();


  String? lastConnectedDeviceAddress;

Future<void> connectToDevice(String address) async {
    if (connection == null || !connection!.isConnected) {
      try {
        connection = await BluetoothConnection.toAddress(address);
        isConnected.add(true); // Notify that the device is connected
        connectedDeviceAddress = address; // Store the connected device address
      } catch (e) {
        print('Error connecting to device: $e');
        isConnected.add(false); // Notify that the device is not connected
        connectedDeviceAddress = null; // Clear the connected device address
      }
    }
  }

  Future<void> sendMessage(String message) async {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(Uint8List.fromList(utf8.encode(message + "\r\n")));
      await connection!.output.allSent;
    }
  }


  void disconnectFromDevice() async {
    if (connection != null && connection!.isConnected) {
      await connection!.close();
      connection = null;
      isConnected.add(false); // Notify that the device is disconnected
      connectedDeviceAddress = null; // Clear the connected device address
    }
  }

  bool get isDeviceConnected => connection?.isConnected ?? false;

  static BluetoothManager get instance => _instance;
}

Future<void> _connect(BluetoothDevice device) async {
  await BluetoothManager.instance.connectToDevice(device.address);
  // Update UI based on connection status
}