import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';

class BluetoothDevicesScreen extends StatefulWidget {
  @override
  _BluetoothDevicesScreenState createState() => _BluetoothDevicesScreenState();
}

class _BluetoothDevicesScreenState extends State<BluetoothDevicesScreen> {
  List<BluetoothDevice> devices = [];
  BluetoothConnection? connection;
  bool isConnecting = false;
  bool isDiscovering = false; // Add a new boolean to track discovery status

  @override
  void initState() {
    super.initState();
    _getBondedDevices();
    _discoverDevices();
  }

  void _getBondedDevices() async {
    List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      devices = bondedDevices;
    });
  }

void _discoverDevices() async {
  // Request necessary permissions at runtime. Adjust according to your needs.
  Map<Permission, PermissionStatus> statuses = await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
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
    setState(() {
      isConnecting = true;
    });

    try {
      final BluetoothConnection connection = await BluetoothConnection.toAddress(device.address);
      print('Connected to the device: ${device.name}');

      setState(() {
        this.connection = connection;
        isConnecting = false;
      });

      connection.input?.listen((Uint8List data) {
        // Handle data from the connected device
      }).onDone(() {
        // Handle disconnection
        if (isConnected) {
          print('Disconnected from the device');
        }
      });
    } catch (e) {
      print('Cannot connect, exception occurred');
      print(e);
      setState(() {
        isConnecting = false;
      });
    }
  }

  bool get isConnected => connection?.isConnected ?? false;

  @override
  void dispose() {
    // Dispose method remains unchanged
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
                  onPressed: () {
                    _discoverDevices();
                  },
                ),
        ],
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          BluetoothDevice device = devices[index];
          return ListTile(
            leading: Icon(Icons.bluetooth),
            title: Text(device.name ?? "Unknown Device"),
            subtitle: Text(device.address),
            onTap: () => _connect(device),
          );
        },
      ),
    );
  }
}
