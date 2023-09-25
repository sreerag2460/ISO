import 'package:flutter/material.dart';
import 'package:iso/constants/colors.dart';

class HomeScreenDisplayBox extends StatelessWidget {
  final String? amount;
  final String? title;
  HomeScreenDisplayBox({this.amount, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: MediaQuery.of(context).size.width / 25),
      height: MediaQuery.of(context).size.height / 7.5,
      width: MediaQuery.of(context).size.width / 3.78,
      decoration: BoxDecoration(
        border: Border.all(color: homeBoxShadow, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(11)),
        color: homeBoxColor,
      ),
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 25.3,
            width: MediaQuery.of(context).size.width / 11.7,
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 54,
                left: MediaQuery.of(context).size.width / 11.02,
                right: MediaQuery.of(context).size.width / 11.36),
            child: Stack(
              children: [
                Container(
                    child: Center(
                        child: Image.asset(
                  'images/ellipse.png',
                  fit: BoxFit.fill,
                ))),
                Center(
                  child: Container(
                      height: MediaQuery.of(context).size.height / 51.3,
                      width: MediaQuery.of(context).size.width / 23.7,
//                                    margin: EdgeInsets.only(right: 2,bottom: 2),
                      child: Image.asset(
                        'images/dollarlogo.png',
                        fit: BoxFit.fill,
                      )),
                ),
              ],
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 270),
            child: Text(
              amount ?? '',
              style: TextStyle(
                  fontFamily: "Quicksand",
                  fontWeight: FontWeight.bold,
                  color: homeAmountColor,
                  fontSize: MediaQuery.of(context).size.height / 54),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 202.5),
            child: Text(
              title ?? "",
              style: TextStyle(
                  fontFamily: "Quicksand",
                  fontWeight: FontWeight.w400,
                  color: homeBoxText,
                  fontSize: MediaQuery.of(context).size.height / 101.25),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
