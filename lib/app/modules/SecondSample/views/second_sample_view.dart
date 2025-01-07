import 'dart:convert';

import 'package:e_c_g_blue_tooth/app/modules/SecondSample/controllers/second_sample_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class SecondSampleView extends StatelessWidget {
  final SecondSampleController controller = Get.put(SecondSampleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Receiver'),
      ),
      body: SingleChildScrollView(
        child: GetBuilder<SecondSampleController>(
          init: controller,
          builder: (controller) {
            return Column(
              children: [
                SizedBox(height: 40),
                Center(
                  child: controller.loader?CircularProgressIndicator(): ElevatedButton(
                    onPressed: () async {
                      await controller.startScan(); // Initiate scanning
                      _showDeviceSelectionBottomSheet(context);
                    },
                    child:  Text('Connect to Device'),
                  ),
        
                ),
                SizedBox(height: 20),
                Center(
                  child:   Text('Connected to device ${controller.connectedDevice?.name??'No device connected'}')
                  ),
                SizedBox(height: 20),
                //add text to show start listening data
                controller.data.length>0? Center(
                  child:   Text('Received data: ${utf8.decode(controller.data)}')
                  ):Container(),
              ]
            );
          }
        ),
      ),
    );
  }

  void _showDeviceSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {

          return

            GetBuilder<SecondSampleController>(
              builder: (_) {
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
}
