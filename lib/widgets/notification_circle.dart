import 'package:flutter/material.dart';
import 'package:iso/constants/colors.dart';

class NotificationCircle extends StatelessWidget {
  final int? number;
  NotificationCircle({this.number});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.height / 70,
        backgroundColor: homeCircleFilled,
        child: Center(
          child: number != null
              ? Text(number.toString(),
                  style: TextStyle(
                      fontFamily: "Quicksand",
                      fontWeight: FontWeight.w400,
                      fontSize: MediaQuery.of(context).size.height / 90,
                      color: Colors.white))
              : SizedBox(),
        ),
      ),
    );
  }
}
