import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  final double size;
  final double opacity;
  final Color background;

  Loading({this.size = 25, this.opacity = 0.1, this.background = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(color: background.withOpacity(opacity)),
      child: Center(
        child: Container(
          width: 50,
          height: 50,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(color: Color(0xFF131d25), borderRadius: BorderRadius.circular(10)),
          child: SpinKitDualRing(
            size: size,
            lineWidth: 2,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
