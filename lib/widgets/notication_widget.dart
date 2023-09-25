import 'package:flutter/material.dart';
import 'package:iso/constants/colors.dart';

class NotificationWidget extends StatelessWidget {
  final String? heading;
  final String? subHeading;
  final Color? onColor;
  final double? top;

  NotificationWidget({this.heading, this.onColor, this.subHeading, this.top});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          top: top ?? 0, left: MediaQuery.of(context).size.width / 25),
      child: Row(
        children: [
          Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 81),
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.height / 55,
              backgroundColor: homeCircleUnfilledBorder,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: MediaQuery.of(context).size.height / 70,
                    backgroundColor: onColor,
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width / 22.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    heading ?? '',
                    style: TextStyle(
                        fontFamily: "Quicksand",
                        fontWeight: FontWeight.bold,
                        color: NotificationHeading,
                        fontSize: MediaQuery.of(context).size.height / 54),
                  ),
                ),
                Container(
                  child: Text(subHeading ?? '',
                      style: TextStyle(
                          fontFamily: "Quicksand",
                          fontWeight: FontWeight.w400,
                          color: NotificationSubHeading,
                          fontSize: MediaQuery.of(context).size.height / 67.5)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
