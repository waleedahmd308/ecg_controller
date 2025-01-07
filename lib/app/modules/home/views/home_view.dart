import 'package:e_c_g_blue_tooth/app/modules/home/controllers/home_controller.dart';
import 'package:e_c_g_blue_tooth/app/modules/home/views/home_stop_start_button.dart';
import 'package:e_c_g_blue_tooth/app/modules/home/views/widgets/graph_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeView extends StatelessWidget {
  final HomeController ecgController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Live ECG Monitoring"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          ecgController.loader
              ? CircularProgressIndicator()
              : IconButton(
                  onPressed: () async {
                    await ecgController.startScan(); // Initiate scanning
                    // Get.to(() => SecondSampleView()); // Add a function to refresh the page
                    // Add a function to disconnect the device
                  },
                  icon: ecgController.deviceConnected
                      ? Icon(Icons.bluetooth)
                      : Icon(Icons.bluetooth_disabled),
                ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // GetBuilder<HomeController>(
          //     init: ecgController,
          //     builder: (controller) {
          //       return ecgController.data.length>0? Center(
          //           child:   Text('Received data: ${utf8.decode(ecgController.data)}')
          //       ):Container();
          //     }
          // ),
          // SizedBox(
          //   height: 50,
          //   ),
          Container(
              height: 290,
              decoration: BoxDecoration(
                //add shadow
                boxShadow: [
                  // BoxShadow(
                  //   color: Colors.black.withOpacity(0.1),
                  //   spreadRadius: 10,
                  //   blurRadius: 10,
                  //   offset: Offset(-1, 10), // changes position of shadow
                  // ),
                ],
                // borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              //color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: GetBuilder(
                init: ecgController,
                builder: (HomeController controller) {
                  double lastTimestampOfCurrent =
                      controller.chartData.isNotEmpty
                          ? controller.chartData.last.timestamp
                          : 0;

                  return Container(
                    height: 180,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.grey[50]!,
                      //border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: SfCartesianChart(
                            backgroundColor:
                                Colors.transparent, // No background here
                            borderWidth: 0.0,
                            plotAreaBorderWidth: 0,
                            key: ValueKey(ecgController.chartKey.value),
                            primaryXAxis: NumericAxis(
                              labelStyle: TextStyle(color: Colors.transparent),
                              isVisible: true,
                              majorGridLines: MajorGridLines(width: 0),

                            ),

                            primaryYAxis: NumericAxis(
                              isVisible:
                                  false, // You may comment this out if you want to adjust the Y-axis settings
                              majorGridLines: MajorGridLines(
                                  width: 0), // Hides horizontal grid lines
                            ),
                            legend: Legend(
                              isVisible: true,
                            ),
                            series: [
                              // Current iteration series (on top)
                              LineSeries<LiveData, int>(
                                animationDuration: 0,
                                dataSource: List.generate(
                                  ecgController.yAxisValues.length,
                                  (i) => LiveData(
                                      ecgController.xAxisTimestamps[i],
                                      ecgController.yAxisValues[i]),
                                ),
                                xValueMapper: (LiveData data, _) =>
                                    data.timestamp.toInt(),
                                yValueMapper: (LiveData data, _) =>
                                    data.ecgSample,
                                pointColorMapper: (LiveData data, int index) =>
                                    getPointColor(index),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )),
          DashBoardIcons(),
          HomeStopStartButton(),
        ],
      ),
    );
  }

  Color getPointColor(int index) {
    return ecgController.chartColors[index];
  }
}
