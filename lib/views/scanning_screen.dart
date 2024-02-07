import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert'; 

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
  if (await Permission.bluetoothConnect.request().isGranted) {
    try {
      final BluetoothConnection connection = await BluetoothConnection.toAddress(device.address);
      print('Connected to the device');

      setState(() {
        this.connection = connection;
        this.connectedDeviceAddress = device.address; // Assuming you declare this variable somewhere
        isConnecting = false;
      });

      // Listen to data coming from Bluetooth
      connection.input?.listen((data) { // Use the conditional access operator `?.`
        print('Data incoming: ${String.fromCharCodes(data)}');
        // Process data
      }).onDone(() {
        // Handle disconnection
        if (this.mounted) { // Check if the widget is still in the widget tree
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
  connection?.dispose();
  streamController.close();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Select a Bluetooth Device"),
      actions: <Widget>[
        isDiscovering
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _discoverDevices,
              ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              BluetoothDevice device = devices[index];
              bool deviceIsConnected = connectedDeviceAddress == device.address;
              return ListTile(
                leading: Icon(Icons.bluetooth),
                title: Text(device.name ?? "Unknown Device"),
                subtitle: Text(device.address),
                trailing: Text(deviceIsConnected ? "Connected" : "Not connected"),
                onTap: () => _connect(device),
              );
            },
          ),
        ),
        if (isConnected) ...[
          TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              labelText: "Send a message",
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _sendMessage(textEditingController.text),
              ),
            ),
          ),
          StreamBuilder<String>(
            stream: streamController.stream,
            builder: (context, snapshot) {
              return Text(snapshot.hasData ? snapshot.data! : "");
            },
          ),
        ]
      ],
    ),
  );
}
}


