import 'package:e_c_g_blue_tooth/app/modules/home/controllers/home_controller.dart';
import 'package:e_c_g_blue_tooth/app/modules/home/views/widgets/home_stop_start_button.dart';
import 'package:e_c_g_blue_tooth/app/modules/home/views/widgets/graph_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeView extends StatelessWidget {
  final HomeController ecgController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double graphHeight = size.height * 0.4; // 40% of screen height
    final double graphWidth = size.width * 0.9;  // 90% of screen width

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Live ECG Monitoring v1.7"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          GetBuilder(
            init: ecgController,
            builder: (controller) {
              return ecgController.loader
                  ? CircularProgressIndicator()
                  : IconButton(
                onPressed: () async {
                  if (ecgController.deviceConnected) {
                    await ecgController.disconnectDevice();
                  }
                  await ecgController.startScan(); // Initiate scanning
                },
                icon: ecgController.deviceConnected
                    ? Icon(Icons.bluetooth)
                    : Icon(Icons.bluetooth_disabled),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: constraints.maxHeight * 0.02), // 2% vertical spacing
                  ecgGraphWidget(graphHeight, graphWidth),
                  SizedBox(height: constraints.maxHeight * 0.02),
                  // DashBoardIcons(),
                  testWidget(),
                  SizedBox(height: constraints.maxHeight * 0.02),
                  HomeStopStartButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget ecgGraphWidget(double height, double width) {
    return Container(
      height: height,
      width: width,
      child: GetBuilder(
        init: ecgController,
        builder: (HomeController controller) {
          return ecgController.deviceConnected
              ? ecgController.showingLoader
              ? Center(child: Text('Loading'))
              : Container(
            decoration: BoxDecoration(
              color: Colors.grey[50]!,
            ),
            child: ecgController.startShowingGraph
                ? SfCartesianChart(
              backgroundColor: Colors.transparent,
              borderWidth: 0.0,
              plotAreaBorderWidth: 0,
              key: ValueKey(ecgController.chartKey.value),
              primaryXAxis: NumericAxis(
                labelStyle: TextStyle(color: Colors.transparent),
                isVisible: true,
                majorGridLines: MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                isVisible: true,
                majorGridLines: MajorGridLines(width: 0),
                title: AxisTitle(
                  text: 'Voltage (V)',
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              legend: Legend(isVisible: false),
              series: [
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
                  pointColorMapper:
                      (LiveData data, int index) =>
                      getPointColor(index),
                ),
              ],
            )
                : Center(
              child: Text(
                  "Press Start to view ECG Graph"),
            ),
          )
              : Center(
            child: Text("Connect to a device to view ECG Graph"),
          );
        },
      ),
    );
  }

  Color getPointColor(int index) {
    return ecgController.chartColors[index];
  }
}

class testWidget extends StatelessWidget {


  var ecgController = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ecgController,
      builder: (ecgController) {
        return Builder(
          builder: (context) {
            return Column(
              children: [
                //Text(ecgController.characteristicsInfo.toString()),
                 Text(ecgController.ackTry.toString()),
                 Text("ack-count:${ecgController.ackCount.toString()}"),
                //  Text(ecgController.ftime.toString()),
                // Text(ecgController.Stime.toString()),
                Text(ecgController.valueTry.toString()),
                 Text("value-count:${ecgController.counter.toString()}")
               // ElevatedButton(onPressed: ecgController.connectAndListenToDevice, child: Text("Connect and Listen to Device")


                // Add more widgets or data as needed

              ],
            );
          }
        );
      }
    );
  }
}
