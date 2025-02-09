import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';

class HomeStopStartButton extends StatelessWidget {
  const HomeStopStartButton({
    super.key,
  });


  @override
  Widget build(BuildContext context) {

    var ecgController = Get.find<HomeController>();
    return GestureDetector(
      onTap: () {
         ecgController.toggleStartStop();

      },
      child: Container(
        width: 60,
        margin: EdgeInsets.only(top: 20),
        height: 60,
        decoration: BoxDecoration(
          //add shadow
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(-1, 3), // changes position of shadow
            ),
          ],
          color: Colors.lightBlueAccent,

          shape: BoxShape.circle,
        ),
        child:
        ecgController.startShowingGraph
            ? Icon(
                Icons.play_arrow,
                size: 40,
                color: Colors.white,
              )
            :
        Icon(
          Icons.stop,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}
