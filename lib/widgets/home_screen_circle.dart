import 'package:flutter/material.dart';
import 'package:iso/constants/colors.dart';

class HomeScreenCircle extends StatelessWidget {
  final int? number;
  final String? circleTitle;
  final Color? circleBackground;
  final Color? textColor;
  final Color? circleBorder;
  HomeScreenCircle(
      {this.number,
      this.circleTitle,
      this.circleBackground,
      this.textColor,
      this.circleBorder});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              border: Border.all(
                  color: circleBorder ?? Colors.transparent, width: 2)),
          child: CircleAvatar(
            radius: MediaQuery.of(context).size.height / 70,
            backgroundColor: circleBackground,
            child: Center(
              child: Text(number.toString(),
                  style: TextStyle(
                      fontFamily: "Quicksand",
                      fontWeight: FontWeight.w400,
                      fontSize: MediaQuery.of(context).size.height / 90,
                      color: textColor)),
            ),
          ),
        ),
        Container(
          child: Text(
            circleTitle ?? '',
            style: TextStyle(
                fontFamily: "Quicksand",
                fontWeight: FontWeight.w400,
                fontSize: MediaQuery.of(context).size.height / 90,
                color: homeCircleTitle),
          ),
        )
      ],
    );
  }
}
