import 'package:flutter/material.dart';

class Roundedbutton extends StatelessWidget {
  Roundedbutton(
      {this.color,
      required this.onPressed,
      this.text,
      this.fontSize,
      this.textOrLoading,
      this.textColor});
  final Color? color;
  void Function()? onPressed;
  final String? text;
  final double? fontSize;
  final Widget? textOrLoading;
  final Color? textColor;
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0.5,
      color: color,
      borderRadius: BorderRadius.circular(30.0),
      child: MaterialButton(
        onPressed: onPressed,
//        minWidth: MediaQuery.of(context).size.width/1.2,
//        height: MediaQuery.of(context).size.height/17.2,
        child: Text(
          text ?? '',
          style: TextStyle(
              color: textColor != null ? textColor : Colors.white,
              fontSize: fontSize,
              fontFamily: "Quicksand",
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
