import 'package:flutter/material.dart';

class RoundedButtonForSearch extends StatelessWidget {
  RoundedButtonForSearch(
      {this.color,
      required this.onPressed,
      this.text,
      this.fontSize,
      this.textColor});
  final Color? color;
  void Function()? onPressed;
  final String? text;
  final double? fontSize;
  final Color? textColor;
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2.0,
      color: color,
      borderRadius: BorderRadius.circular(30.0),
      child: MaterialButton(
        onPressed: onPressed,
//        minWidth: MediaQuery.of(context).size.width/1.2,
//        height: MediaQuery.of(context).size.height/17.2,
        child: Text(
          text ?? '',
          style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontFamily: "Quicksand",
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
