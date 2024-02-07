import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';


class BluetoothDevicesScreen extends StatefulWidget {
  @override
  _BluetoothDevicesScreenState createState() => _BluetoothDevicesScreenState();
}

class _BluetoothDevicesScreenState extends State<BluetoothDevicesScreen> {
  List<BluetoothDevice> devices = [];
  BluetoothConnection? connection; // Marked as nullable
  bool isConnecting = false; // Updated to reflect initial state

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

  void _discoverDevices() {
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
      // Discovery is done
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
    // Dispose the connection when the widget is disposed
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select a Bluetooth Device"),
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
