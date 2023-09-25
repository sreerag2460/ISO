import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:iso/constants/colors.dart';

class DottedSeparator extends StatelessWidget {
  const DottedSeparator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height / 65, left: 5),
      child: DottedLine(
        direction: Axis.horizontal,
        lineLength: MediaQuery.of(context).size.width / 9.86,
        lineThickness: 3,
        dashRadius: 50,
        dashColor: dottedLineColor,
        dashLength: 2,
      ),
    );
  }
}
