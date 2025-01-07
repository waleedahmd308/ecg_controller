import 'package:flutter/material.dart';

class HomeStopStartButton extends StatelessWidget {
  const HomeStopStartButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ecgController.timer.cancel();
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
        child: Icon(
          Icons.stop,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}
