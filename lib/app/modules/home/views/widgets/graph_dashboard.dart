import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class DashBoardIcons extends StatelessWidget {
  const DashBoardIcons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.grey[200],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ParameterDisplay(title: "PR Interval", value: "153", unit: "ms"),
              Container( width: 1,height: 60,color:Colors.black.withOpacity(0.1),),
              ParameterDisplay(title: "QRS Duration", value: "122", unit: "ms")
            ],
          ),
        ),
        // const SizedBox(height: 6),
        Container(
          color: Colors.grey[200],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ParameterDisplay(title: "QT / QTcB", value: "383/420", unit: "ms"),
              Container( width: 1,height: 60,color:Colors.black.withOpacity(0.1),),
              ParameterDisplay(title: "P Wave", value: "108", unit: "ms"),
            ],
          ),
        ),
        // const SizedBox(height: 6),
        Container(
          color: Colors.grey[200],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ParameterDisplay(title: "RR Interval", value: "875", unit: "ms"),
              Container( width: 1,height: 60,color:Colors.black.withOpacity(0.1),),
              ParameterDisplay(title: "PP Interval", value: "870", unit: "ms"),
            ],
          ),
        ),
      ],
    );
  }
}


class ParameterDisplay extends StatelessWidget {
  final String title;
  final String value;
  final String? unit; // Optional unit like "ms"
  const ParameterDisplay({
    Key? key,
    required this.title,
    required this.value,
    this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 70,
      // color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 12, // Smaller font size for title
              fontWeight: FontWeight.bold,
              color: Colors.grey[600], // Lighter color
            ),
          ),
          const SizedBox(height: 4),
          // Value and Unit
          RichText(
            text: TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 18, // Larger font size for value
                fontWeight: FontWeight.bold,
                color: Colors.black, // Dark color for value
              ),
              children: [
                if (unit != null)
                  TextSpan(
                    text: " $unit",
                    style: TextStyle(
                      fontSize: 16, // Slightly smaller for the unit
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}