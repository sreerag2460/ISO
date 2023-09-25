import 'package:flutter/material.dart';

class RoundedButtonUpload extends StatelessWidget {
  RoundedButtonUpload(
      {this.color,
      required this.onPressed,
      this.fontSize,
      this.textOrLoading,
      this.textColor,
      this.textLoader});
  final Color? color;
  void Function() onPressed;
  final Widget? textLoader;
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
          child: textLoader),
    );
  }
}
