import 'package:flutter/material.dart';
import 'package:iso/constants/colors.dart';

class RoundedbuttonProfile extends StatelessWidget {
  RoundedbuttonProfile(
      {this.color, required this.onPressed, this.text, this.fontSize});
  final Color? color;
  void Function()? onPressed;
  final String? text;
  final double? fontSize;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width / 1.15,
        height: MediaQuery.of(context).size.height / 20.25,
        margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height / 40.5,
            left: MediaQuery.of(context).size.width / 15),
        decoration: BoxDecoration(
            border: Border.all(color: textFieldBorder, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(30)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: textFieldShadow.withOpacity(1),
                  blurRadius: 10,
                  offset: Offset(0, 3))
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 19.74),
              child: Text(
                text ?? '',
                style: TextStyle(
                    color: hintTextColor,
                    fontSize: fontSize,
                    fontFamily: "Quicksand",
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width / 18.79),
              child: Image.asset('images/uploadSmallIcon.png'),
            )
          ],
        ),
      ),
    );
  }
}
