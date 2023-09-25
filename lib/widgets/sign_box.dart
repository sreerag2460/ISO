import 'package:flutter/material.dart';
import 'package:iso/constants/colors.dart';

class SignBox extends StatelessWidget {
  final String? title;
  final double? opacity;
  SignBox({this.title, this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity ?? 0,
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        height: MediaQuery.of(context).size.height / 7.29,
        margin:
            EdgeInsets.only(left: MediaQuery.of(context).size.width / 14.42),
        decoration: BoxDecoration(
            border: Border.all(color: signBoxBorder, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(16)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: signBoxShadow.withOpacity(1),
                  blurRadius: 20,
                  offset: Offset(0, 0))
            ]),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 57.85),
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.height / 30,
                backgroundColor: signBoxCircle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width / 13.7,
                        height: MediaQuery.of(context).size.height / 28.85,
                        child: Image.asset('images/signIcon.png'))
                  ],
                ),
              ),
            ),
            Container(
              margin:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 81),
              child: Text(
                title ?? '',
                style: TextStyle(
                    fontFamily: "Quicksand",
                    fontWeight: FontWeight.bold,
                    color: signBoxText,
                    fontSize: MediaQuery.of(context).size.height / 73.63),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
