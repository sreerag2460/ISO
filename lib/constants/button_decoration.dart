import 'package:flutter/material.dart';
import 'package:iso/constants/colors.dart';
const kuserInputButtons = InputDecoration(
//  hintText: 'Enter your mobile number',
  hintStyle: TextStyle(fontFamily: 'Quicksand', fontWeight: FontWeight.w400,color: hintTextColor),
  fillColor: Colors.white,
  filled: true,
  counterText: "",
  contentPadding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: textFieldBorder, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: textFieldBorder, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);