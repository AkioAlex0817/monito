import 'package:flutter/material.dart';

class RoundLabel extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final double fontSize;
  final double size;
  final double height;

  RoundLabel({this.label, this.backgroundColor, this.fontSize, this.size = 0, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: this.backgroundColor, borderRadius: BorderRadius.all(Radius.circular(5))),
      margin: EdgeInsets.only(left: size),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
