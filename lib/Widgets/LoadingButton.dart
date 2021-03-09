import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingButton extends StatelessWidget {
  Color color;
  bool disabled;
  bool loading;
  String title;
  Color fontColor;
  double fontSize;
  Color loadingColor;
  double loadingSize;
  VoidCallback onPressed;
  double borderRadius;


  LoadingButton({this.color, this.disabled, this.loading, this.title, this.fontColor, this.fontSize, this.loadingColor, this.loadingSize, this.onPressed, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Material(
        color: disabled ? Colors.grey : color,
        child: InkWell(
          onTap: loading
              ? null
              : () {
                  onPressed();
                },
          child: Container(
            constraints: BoxConstraints.expand(),
            alignment: Alignment.center,
            child: loading ? SpinKitFadingCircle(color: loadingColor, size: loadingSize) : Text(title, style: TextStyle(color: fontColor, fontSize: fontSize)),
          ),
        ),
      ),
    );
  }
}
