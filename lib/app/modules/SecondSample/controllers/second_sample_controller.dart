import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class SecondSampleController extends GetxController {
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? targetCharacteristic;
  bool loader = false;
  List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  String receivedData = "No data received";

  //create a list to get data
   List<int> data=[];


  // Initialize FlutterBluePlus instance

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> _requestPermissions() async {
    BuildContext context=Get.context!;
    if (!await Permission.locationWhenInUse.isGranted) {
      await Permission.locationWhenInUse.request();
    }
    if (!await Permission.bluetoothScan.isGranted) {
      await Permission.bluetoothScan.request();
    }
    if (!await Permission.bluetoothConnect.isGranted) {
      await Permission.bluetoothConnect.request();
    }
  }

  Future<void> showBondedDevices() async {
    List<BluetoothDevice> connectedDevices = await FlutterBluePlus.bondedDevices;

    if (connectedDevices.isNotEmpty) {
      for (BluetoothDevice device in connectedDevices) {
        print('Bonded Device: ${device.name}, ID: ${device.id}');
        devicesList.add(device);
        update();
      }
    } else {
      print('No bonded devices found');
    }
  }

  Future<void> startScan() async {
    //show alert if bluetooth is off
    BuildContext context=Get.context!;
    if (!await FlutterBluePlus.isOn) {
      showDialog(context: context, builder: (context) => AlertDialog(
        title: Text('Bluetooth Required'),
        content: Text('Please enable bluetooth to use this app'),
    ));
      return;
    }
    await _requestPermissions();
    if (await Permission.locationWhenInUse.isGranted &&
        await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted) {
      devicesList.clear();
      update();

      FlutterBluePlus.startScan(timeout: Duration(seconds: 15));

      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (!devicesList.contains(result.device)) {
            devicesList.add(result.device);
            update();
          }
        }
      });
      showBondedDevices();
    } else {
      print("Required permissions not granted");
      showDialog(context: context, builder: (context) => AlertDialog(
          title: Text('Permission Required'),
    content: Text('Please enable location permission to use this app'),
    ));
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    loader=true;
    update();
    await device.connect();
    loader=false;
    update();
    connectedDevice = device;

    // show dilog
    showDialog(context: Get.context!, builder: (context) => AlertDialog(
      title: Text('Connected'),
      content: Text('Connected to ${device.name}'),
    ));
    update();
    List<BluetoothService> services = await device.discoverServices();
    print('Discovered services: $services');
    for (var service in services) {
      for (var characteristic in service.characteristics) {
         if(characteristic.properties.read){
           targetCharacteristic = characteristic;
           print('Characteristic found: ${targetCharacteristic!}');
           //show toast
            break;
         }
      }
    }
    connectAndListenToDevice();
    Get.snackbar('Characteristic Found', 'Characteristic found: ${targetCharacteristic}');

  }



  Future<void> getConnectedDevices() async {
    print('Getting connected devices...');
    List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
    print(devices);
    if (devices.isNotEmpty) {
      connectToDevice(devices.first);
      print('Connected to: ${devices.first.name}');
    }
  }


  Future<void> disconnectDevice() async {
    await connectedDevice?.disconnect();
    connectedDevice = null;
    update();
  }
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();


  Future<void> connectAndListenToDevice() async {
    if (targetCharacteristic == null) {
      print("No target characteristic found.");
      return;
    }

    try {

      await targetCharacteristic!.setNotifyValue(true);

      targetCharacteristic!.onValueReceived.listen((value) {

        //receivedData = utf8.decode(value);
       data=value;

        print('---------------------------------------------------');
        print("Received Data: ${utf8.decode(data)}");
        print('---------------------------------------------------');
        update();
      });

    } catch (e) {
      print("Error while setting up notifications: $e");
    }
  }

}
