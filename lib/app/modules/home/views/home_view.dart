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
                    if(ecgController.deviceConnected){

                      await ecgController.disconnectDevice();}
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
          ecgGraphWidget(context),
          DashBoardIcons(),
          HomeStopStartButton(),
        ],
      ),
    );
  }

  Container ecgGraphWidget(BuildContext context) {
    return  Container(
            height: 290,
            width: MediaQuery.of(context).size.width,
            child: GetBuilder(
              init: ecgController,
              builder: (HomeController controller) {
                return
                ecgController.deviceConnected?ecgController.showingLoader?Center(child: Text('Loading')): Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.grey[50]!,
                    //border: Border.all(color: Colors.grey[300]!),
                  ),
                  child:ecgController.startShowingGraph? SfCartesianChart(
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
                          true, // You may comment this out if you want to adjust the Y-axis settings
                      majorGridLines: MajorGridLines(
                          width: 0), // Hides horizontal grid lines
                      title: AxisTitle(
                        text: 'Voltage (V)', // Title for Y-axis
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    legend: Legend(
                      isVisible: false,
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
                  ):Container(
                    child: Center(
                      child: Text("Press Start to view ECG Graph"),
                    ),
                  ),
                ):Container(
                  child: Center(
                    child: Text("Connect to a device to view ECG Graph"),
                  ),
                );
              },
            ));
  }

  Color getPointColor(int index) {
    return ecgController.chartColors[index];
  }
}
