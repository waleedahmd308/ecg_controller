import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:e_c_g_blue_tooth/app/modules/SecondSample/controllers/second_sample_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../SecondSample/views/second_sample_view.dart';

class HomeController extends GetxController {
  late final RxList<LiveData> chartData = <LiveData>[].obs;
  late final RxList<LiveData> chartData2 = <LiveData>[].obs;
  List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  bool loader = false;
  bool deviceConnected = false;
  List<int> data=[];

  var shouldListen = false;

  var startShowingGraph = true;
  var showingLoader=false;


  var dataController= SecondSampleController();

  var xAxisTimestamps= <double>[].obs;
  var yAxisValues= <double>[].obs;
  double plotBandEnd = 300; // Initial value for plot band end
  late Timer timer;
  var chartKey = 0.obs;
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? targetCharacteristic;

  var heartRate = 0;
  var respirationRate=0;
  var spo2=0;


  @override
  void onInit() {
    super.onInit();
    // chartData.addAll(generateRandomChartData());
    // chartData2.addAll(generateRandomChartData());
    showNoBlueToothDilouge();
    loader=false;


    //startAnimation();
    Timer.periodic(Duration(seconds: 5), (timer) {

      update();
    });
  }


  void toggleStartStop() {
     
    //add timeout for 5 seconds
    if(startShowingGraph==false){
      showingLoader=true;

      update();
      Future.delayed(Duration(seconds: 3), () {
        showingLoader=!showingLoader;
      });
    }

    
    startShowingGraph = !startShowingGraph;
    update();

  }
  void showNoBlueToothDilouge(){

    if(FlutterBluePlus.isOn==false){
      Get.defaultDialog(
        title: "Bluetooth Required",
        content: Text('Please enable bluetooth to use this app'),
      );
    }


  }
  int index=0;
  final int maxTimeStamps=250;
  List<Color> chartColors = [];


  void cycleDataEnhance(double time, double value) {
    // Add new data points to the chart
    if (xAxisTimestamps.isEmpty) {
      for (int i = 0; i < maxTimeStamps; i++) {
        xAxisTimestamps.add(time + i);
      }
    }
    int startIndex = index;
    int endIndex = (index + 1) % maxTimeStamps;
    print('end $endIndex');
    print('start $startIndex');

    print(yAxisValues.length);
    if (yAxisValues.length < maxTimeStamps) {
      yAxisValues.add(value);
      chartColors.add(Colors.blue);
    } else {
      yAxisValues[index] = value;
      index = (index + 1) % maxTimeStamps;
    }

    if (chartData.length > maxTimeStamps  ) {
      chartData.removeRange(0, chartData.length - maxTimeStamps);
    }


    //for color
    for (int i = 10; i < yAxisValues.length; i++) {
      if ((startIndex <= endIndex && i >= startIndex && i <= endIndex) ||
          (startIndex > endIndex && (i >= startIndex || i <= endIndex))) {
        chartColors[i] = Colors.white; // Updated points
      } else {
        chartColors[i] = Colors.blue; // Unchanged points
      }
    }
    // Notify observers
    update();
  }

  Future<void> _requestPermissions() async {
    BuildContext context = Get.context!;

    // Request location permissions
    if (await Permission.location.isDenied || await Permission.location.isPermanentlyDenied) {
      await Permission.location.request();
    }

    // Request locationWhenInUse permissions
    if (await Permission.locationWhenInUse.isDenied || await Permission.locationWhenInUse.isPermanentlyDenied) {
      await Permission.locationWhenInUse.request();
    }

    // Request Bluetooth permissions for Android 12+
    if (await Permission.bluetoothScan.isDenied || await Permission.bluetoothScan.isPermanentlyDenied) {
      await Permission.bluetoothScan.request();
    }

    if (await Permission.bluetoothConnect.isDenied || await Permission.bluetoothConnect.isPermanentlyDenied) {
      await Permission.bluetoothConnect.request();
    }

  }


  Future<void> showBondedDevices() async {
    List<BluetoothDevice> connectedDevices = await FlutterBluePlus.bondedDevices;

    if (connectedDevices.isNotEmpty) {
      for (BluetoothDevice device in connectedDevices) {
        print('Bonded Device: ${device.name}, ID: ${device.id}');

        devicesList.add(device);
        update();}

    } else {
      print('No bonded devices found');
    }
  }

  Future<void> startScan() async {
    //show alert if bluetooth is off
    BuildContext context=Get.context!;
    if (!await FlutterBluePlus.isOn) {
      showStyledDialog('Bluetooth Required','Please enable bluetooth to use this app',context,false);
      return;
    }
    await _requestPermissions();
    if (await Permission.locationWhenInUse.isGranted &&
        await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted) {
      devicesList.clear();
      update();

      FlutterBluePlus.startScan(timeout: Duration(seconds: 15));
      showBondedDevices();
      FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
        for (ScanResult result in results) {
          BluetoothDevice device = result.device;
// Avoid duplicates and add the device to the list
          if (!devicesList.contains(device)) {
            devicesList.add(device);
            update(); // Update UI
          }
        }
      });
        _showDeviceSelectionBottomSheet(context);
    } else {
      print("Required permissions not granted");

      showStyledDialog('Location Permission Required','Please enable location permission to use this app',context,true);

    }
  }



  Future<void> disconnectDevice() async {

    BuildContext context=Get.context!;
    //showStyledDialog('Alert', 'Do you realy want to disconnect the app?', context, true);
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      connectedDevice = null;
      deviceConnected=false;

      update();
    }
  }
  Future<void> connectToDevice(BluetoothDevice device) async {
    // loader=true;
    // update();
    // try{
     await device.connect();
     loader=false;
    update();
    connectedDevice = device;

    // show dilog
    Get.snackbar('Success', 'Connected to ${device.name}');
    deviceConnected=true;
    update();
    List<BluetoothService> services = await device.discoverServices();
    print('Discovered services: $services');
    for (var service in services) {
      for (var characteristic in service.characteristics) {

        if(characteristic.properties.read){
          targetCharacteristic = characteristic;
          print('Characteristic found: ${targetCharacteristic!}');
          break;
        }
      }
    }
    connectAndListenToDevice();
    // }catch(e){
    //   Get.snackbar('Error', 'Error connecting to ${device.name}');
    //   loader=false;
    //
    // }
   }

  Future<void> connectAndListenToDevice() async {

    print(' values it shi $targetCharacteristic');
    if (targetCharacteristic == null) {
      print("No target characteristic found.");
      return;
    }
    print(targetCharacteristic);
    try {

      await targetCharacteristic!.setNotifyValue(true);

      targetCharacteristic!.onValueReceived.listen((value) async {
        String receivedData = utf8.decode(value);
        String cleanedData = receivedData.replaceAll(RegExp(r'[\[\]]'), '');
        List<String> packets = cleanedData.split('),(');
        double? timeStamp;
        double? voltage;
        for(var packet in packets){
          String cleanedObject = packet.replaceAll(RegExp(r'[()]'), '');
          List<String> values = cleanedObject.split(',');
             if(values.length==2){
                timeStamp = double.tryParse(values[0].trim());
                voltage = double.tryParse(values[1].trim());
                 if (timeStamp != null && voltage != null) {
                    cycleDataEnhance(timeStamp,voltage);
                 } else {
                    print('Error parsing packet: $cleanedObject');
                 }
             }
        }
        update();
      });
    } catch (e) {
      print("Error while setting up notifications: $e");
    }
  }

  Map<String, dynamic> parseJsonData(String jsonData) {
    return jsonData.startsWith('{') ? Map<String, dynamic>.from(jsonDecode(jsonData)) : {};
  }
  void showStyledDialog(String TextTitle,String detailsText,BuildContext context,bool isPermission) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.orange.withOpacity(0.2),
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.orange,
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                TextTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                detailsText,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  isPermission?openAppSettings() :null;
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                ),
                child: Text(
                  isPermission?'OK':'Close',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}





void _showDeviceSelectionBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {

      return

        GetBuilder<HomeController>(
            builder: (controller) {
              if (controller.devicesList.isEmpty) {
                return Center(child: Text('No devices found'));
              } else {

                return Container(
                  padding: EdgeInsets.all(16),
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: controller.devicesList.isEmpty
                      ? Center(child: Text('No devices found'))
                      : Column(
                    children: [
                      Text(
                        'Available Devices',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: controller.devicesList.length,
                          itemBuilder: (context, index) {
                            BluetoothDevice device = controller.devicesList[index];
                            return ListTile(
                              title: Text(device.name.isEmpty ? 'Unknown Device' : device.name),
                              subtitle: Text(device.id.toString()),
                              trailing: controller.loader?CircularProgressIndicator():null,
                              onTap: () {
                                Navigator.pop(context); // Close the bottom sheet
                                controller.connectToDevice(device); // Connect to the selected device
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );}
            }
        );

    },
  );
}

class LiveData {
  final double timestamp;
  final num ecgSample;
  LiveData(this.timestamp, this.ecgSample);
}
