import 'package:flutter/material.dart';

class LabelWidget extends StatelessWidget {
  final Color color;
  final String label;
  final double fontSize;

  LabelWidget({this.color, this.label, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.all(Radius.circular(5))),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold),
        maxLines: 1,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
