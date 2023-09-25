import 'package:flutter/material.dart';
import 'package:iso/constants/colors.dart';

class DrawerTab extends StatelessWidget {
  DrawerTab({this.text, this.image, this.top, this.onTap});
  final String? text;
  final String? image;
  final double? top;
  void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        margin: EdgeInsets.only(left: _size.width / 20, top: top ?? 0),
        child: Row(
          children: [
            Container(
              height: _size.height / 45.76,
              width: _size.width / 25,
              child: image != null ? Image.asset(image!) : SizedBox(),
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(text ?? '',
                  style: TextStyle(
                      fontFamily: "Quicksand",
                      fontWeight: FontWeight.bold,
                      fontSize: _size.height / 58,
                      color: homeClientName)),
            )
          ],
        ),
      ),
    );
  }
}

class DrawerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Container(
      height: 1,
      width: MediaQuery.of(context).size.width / 1.5,
      margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height / 35.37,
          left: _size.width > 650 ? _size.width / 20 : _size.width / 11.02,
          right: _size.width / 8.82),
      color: lineColor,
    );
  }
}

class ContactTab extends StatelessWidget {
  ContactTab({this.text, this.top, this.image});
  final String? text;
  final String? image;
  final double? top;
  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(left: _size.width / 20, top: top ?? 0),
      child: Row(
        children: [
          Container(
            height: _size.height / 45.76,
            width: _size.width / 25,
            child: image != null ? Image.asset(image!) : SizedBox(),
          ),
          SizedBox(
            width: 15,
          ),
          Container(
            child: Flexible(
              child: Text(text ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: "Quicksand",
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: homeBoxText)),
            ),
          )
        ],
      ),
    );
  }
}
