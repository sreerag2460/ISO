import 'package:flutter/material.dart';
import 'package:iso/constants/colors.dart';

class DetailedTelephone extends StatelessWidget {
  final String? number;
  DetailedTelephone({this.number});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width / 25),
          height: MediaQuery.of(context).size.width > 650
              ? MediaQuery.of(context).size.height / 21.89
              : null,
          width: MediaQuery.of(context).size.width > 650
              ? MediaQuery.of(context).size.width / 15
              : null,
          child: Image.asset(
            'images/telephoneColored.png',
            fit: MediaQuery.of(context).size.width > 650
                ? BoxFit.fill
                : BoxFit.none,
          ),
        ),
        Container(
          margin:
              EdgeInsets.only(left: MediaQuery.of(context).size.width / 37.5),
          child: Text(number ?? '',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height / 45,
                  fontFamily: "Quicksand",
                  fontWeight: FontWeight.bold,
                  color: uploadDocumentsTitle)),
        )
      ],
    );
  }
}
