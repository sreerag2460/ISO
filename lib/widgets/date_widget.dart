import 'package:flutter/material.dart';
import 'package:iso/constants/colors.dart';
import 'dart:io';

class DateWidget extends StatelessWidget {
  final double? leftMargin;
  final DateTime? text;
  final String? hintText;
  void Function()? onTap;
  void Function()? onTapIOS;
  DateWidget(
      {this.leftMargin, this.text, this.onTap, this.hintText, this.onTapIOS});

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: Platform.isIOS ? onTapIOS : onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 2.4,
        height: MediaQuery.of(context).size.height / 23,
        margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height / 54,
            left: leftMargin ?? 0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            border: Border.all(color: textFieldBorder, width: 1),
            boxShadow: [
              BoxShadow(
                  color: textFieldShadow.withOpacity(1),
                  blurRadius: 10,
                  offset: Offset(0, 3)),
            ]),
        child: Container(
          margin: EdgeInsets.only(
              left: _size.width / 19.74, right: _size.width / 31.35),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  (text != null
                      ? "${text?.month.toString()}-${text?.day.toString()}-${text?.year.toString()}"
                          .split(' ')[0]
                      : hintText ?? ''),
                  style: TextStyle(
                      color: hintTextColor,
                      fontFamily: "Quicksand",
                      fontWeight: FontWeight.w400,
                      fontSize: MediaQuery.of(context).size.height / 81)),
              Image.asset('images/calenderIcon.png')
            ],
          ),
        ),
      ),
    );
  }
}
