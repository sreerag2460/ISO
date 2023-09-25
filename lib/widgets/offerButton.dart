import 'package:flutter/material.dart';

class OfferButton extends StatelessWidget {
  final Color? color;
  void Function()? onPressed;
  final String? text;
  final Color? textColor;
  OfferButton({this.text, this.onPressed, this.color, this.textColor});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(30.0),
      child: MaterialButton(
        onPressed: onPressed ?? () {},
//        minWidth: MediaQuery.of(context).size.width/1.2,
//        height: MediaQuery.of(context).size.height/17.2,
        child: Text(
          text ?? '',
          style: TextStyle(
              color: textColor,
              fontSize: MediaQuery.of(context).size.height / 54,
              fontFamily: "Quicksand",
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
