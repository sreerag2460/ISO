import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  LoginButton(
      {this.color, required this.onPressed, this.fontSize, this.textOrLoading});
  final Color? color;
  void Function()? onPressed;

  final double? fontSize;
  final Widget? textOrLoading;
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
          child: textOrLoading),
    );
  }
}
