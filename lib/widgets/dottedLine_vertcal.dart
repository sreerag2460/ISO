import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:iso/constants/colors.dart';

class DottedLineVertical extends StatelessWidget {
  const DottedLineVertical({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width > 650
              ? MediaQuery.of(context).size.width / 16
              : MediaQuery.of(context).size.width / 14),
      child: DottedLine(
        direction: Axis.vertical,
        lineLength: MediaQuery.of(context).size.width / 9.86,
        lineThickness: 3,
        dashRadius: 50,
        dashColor: dottedLineColor,
        dashLength: 2,
      ),
    );
  }
}
