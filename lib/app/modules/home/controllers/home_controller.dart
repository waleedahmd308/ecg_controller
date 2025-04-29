import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
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

  var dataTest = [];
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
    //startFakeStream();
  }


  void toggleStartStop() {

    if(startShowingGraph==false){
      showingLoader=true;

      update();
      Future.delayed(Duration(seconds: 2), () {
        showingLoader=!showingLoader;
      });
    }


    startShowingGraph = !startShowingGraph;
    update();

  }

  Future<void> stopReceivingData() async {
    if (targetCharacteristic != null) {
      try {
        await targetCharacteristic!.setNotifyValue(false);
        print("🛑 Unsubscribed from notifications.");
      } catch (e) {
        print("Error while stopping notifications: $e");
      }
    }
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
      // showBondedDevices();
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
      startShowingGraph=false;
      update();
      update();
    }
  }
  String getServices='';
  String failedCheck='';
  String characteristicsInfo = '';
  BluetoothCharacteristic? ackCharacteristic;
    Future<void> connectToDevice(BluetoothDevice device) async {
      // loader=true;
      // update();
      try {
        await device.connect();

           await Future.delayed(Duration(milliseconds: 300));
           print('MTU requested hua h: 247');
        await device.requestMtu(245);
        await Future.delayed(Duration(milliseconds: 500));



         print('Connected to device: ${device.name}');
         List<BluetoothService> services = await device.discoverServices();

        // loader = false;
        // update();
        // connectedDevice = device;
        // startShowingGraph = true;
        //

        //
        //  failedCheck='MTU requested: 247';
        //  print('MTU requested: 247');
        //  update();


        // show dilog
        Get.snackbar('Success', 'Connected to ${device.name}');
        // int mtu = await device.requestMtu(245);
        // AlertDialog(
        //   title: Text('MTU requested'),
        //   content: Text('MTU requested: $mtu'),
        // );


        // deviceConnected = true;
        // update();
        // await Future.delayed(Duration(milliseconds: 500)); // before discovering services
        //
        //   List<BluetoothService> services = await device.discoverServices();
        //   return ;

        // print('Discovered services:');
        // getServices=services.toString();
        // update();


       // return;
        characteristicsInfo = ''; // Clear before adding new
        for (var service in services) {
          for (var characteristic in service.characteristics) {
            final uuid = characteristic.uuid.toString();
            final props = characteristic.properties;

            characteristicsInfo +=
            'UUID: $uuid\n'
                '  read: ${props.read}, write: ${props.write}, '
                'writeWithoutResponse: ${props.writeWithoutResponse}, notify: ${props.notify}\n\n';

            if (uuid.toLowerCase() == '19b10001-e8f2-537e-4f6c-d104768a1214') {
              targetCharacteristic = characteristic;
            }
            else if (uuid.toLowerCase() == '19b10002-e8f2-537e-4f6c-d104768a1214') {
              ackCharacteristic = characteristic;
            }
          }
        }
        update();

        for (var service in services) {
          for (var characteristic in service.characteristics) {
            final uuid = characteristic.uuid.toString().toLowerCase();
            if (uuid == '19b10001-e8f2-537e-4f6c-d104768a1214') {
              targetCharacteristic = characteristic;
              print('Target characteristic set: ${targetCharacteristic!.uuid}');
              break;
            }
            else if (uuid == '19b10002-e8f2-537e-4f6c-d104768a1214') {
              ackCharacteristic = characteristic;
              print('📤 Ack Characteristic set: ${characteristic.uuid}');
            }
          }
          if (targetCharacteristic != null) break;
        }
        failedCheck='target characteristic set: ${targetCharacteristic} + ack charteric set: ${ackCharacteristic}';
        update();
        connectAndListenToDevice();
      } catch (e) {

        print('Error connecting to device: $e');
        loader = false;
        failedCheck='Failed to connect to device: $e';
        update();
       // Get.snackbar('Error', 'Failed to connect to ${device.name}');

      }

     }
  //int fakePacketId = 1;
  // Map<String, dynamic> generateFakePacket(int id) {
  //   Random random = Random();
  //   List<double> sValues = List.generate(31, (_) => double.parse((random.nextDouble() * 0.3).toStringAsFixed(3)));
  //
  //   return {
  //     "id": id,
  //     "s": sValues,
  //   };
  // }
  // void handleIncomingData(String receivedString) {
  //   try {
  //     Map<String, dynamic> jsonData = jsonDecode(receivedString);
  //     List<dynamic> signalValues = jsonData['s'];
  //
  //     for (var i = 0; i < signalValues.length; i++) {
  //       double val = signalValues[i].toDouble();
  //       cycleDataEnhance(globalTime, val);
  //       print('⏱ Sending to graph: Time = $globalTime, Value = $val');
  //       globalTime += 0.4;
  //     }
  //   } catch (e) {
  //     print('❌ Error parsing data: $e');
  //   }
  // }
  // void startFakeStream() {
  //   Timer.periodic(Duration(seconds: 1), (timer) {
  //     Map<String, dynamic> fakePacket = generateFakePacket(fakePacketId);
  //     String fakeJson = jsonEncode(fakePacket);
  //
  //     print('📦 Simulated Packet: $fakeJson');
  //
  //     // Simulate what the real listener does
  //     handleIncomingData(fakeJson);
  //
  //     fakePacketId++;
  //   });
  // }    W2```````````````````````````````````````````````
  double globalTime = 0.0;
  String pakcetLossText='🔵 No Raw Received (testing)';


  int previousPacketId = -1; // initialize with an invalid starting value
  int lostPacketCount = 0;


  String receivedStringGlobal='';
  String noError='';

  String firstTryNoError='';
  String firstTryError='';

  int counter=0;

  Future<void> connectAndListenToDevice() async {
    if (targetCharacteristic == null || ackCharacteristic == null) {
      print("Missing characteristic.");
      failedCheck='Target characteristic is null + ack characteristic is null';
      return;
    }
    else{
      failedCheck='Target characteristic is not null + ack characteristic is not null';
      update();
    }

    try {
      await targetCharacteristic!.setNotifyValue(true);
      targetCharacteristic!.onValueReceived.listen((value) async {
        receivedStringGlobal='🔵 Raw Received: ${utf8.decode(value)}';
        try {
          print('🟡 Sending ACK...');

          await ackCharacteristic!.write(
            utf8.encode(jsonEncode({"r": counter})),
            withoutResponse: false,
          );
          failedCheck='✅ ACK sent';
          update();
        } catch (e) {
          print('❌ Failed to send ACK: $e');
          failedCheck='❌ Failed to send ACK: $e';
          update();
        }

        print('✅ ACK sent to device');
        counter++;
        update();


         // Future.microtask(() {
         //
         //   try{
         //     String receivedString = utf8.decode(value);
         //     // print('🔵 Raw Received: $value');
         //     // failedCheck='🔵Raw Received: $value';
         //
         //     Map<String, dynamic> jsonData = jsonDecode(receivedString);
         //     L     ist<dynamic> signalValues = jsonData['s'];
         //
         //     var packetId = jsonData['id'];
         //     // receivedStringGlobal+="🔵 Data Received "+receivedString;
         //     noError='✅ Received: String Assign to recievedString';
         //     update();
         //   } catch(e){
         //     print('Error in onValueReceived: $e');
         //     noError='❌ Error in onValueReceived: $e';
         //      update();
         //   }
         //
         // });


        // Packet loss logic
        // if (previousPacketId != -1) {
        //   int expectedId = (previousPacketId + 1) % 10;
        //   if (packetId != expectedId) {
        //     lostPacketCount++;
        //     pakcetLossText =
        //     '⚠️ Packet loss detected! Expected: $expectedId, Received: $packetId, Total Lost: $lostPacketCount';
        //     print(pakcetLossText);
        //   }
        // }
      //  previousPacketId = packetId;

        // Process signal values
              String receivedString = utf8.decode(value);
              // print('🔵 Raw Received: $value');
              // failedCheck='🔵Raw Received: $value';

              Map<String, dynamic> jsonData = jsonDecode(receivedString);
              List<dynamic> signalValues = jsonData['s'];

              //var packetId = jsonData['id'];
               receivedStringGlobal+="🔵 Data Received "+receivedString;
              // noError='✅ Received: String Assign to recievedString';
               update();
        for (var i = 0; i < signalValues.length; i++) {
          double val = signalValues[i].toDouble();
          cycleDataEnhance(globalTime, val);
          noError='⏱ Sending to graph: Time = $globalTime, Value = $val';
          update();
          globalTime += 0.32;
        }


        // ✅ Send ACK after processing



        firstTryNoError='✅ ACK sent to device (outer try)';
        update();
      });
    } catch (e) {
      print("Error while setting up notifications: $e");
      firstTryNoError='✅Error (outer try): $e';
      update();
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
