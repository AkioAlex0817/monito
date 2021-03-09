import 'package:flutter/material.dart';
import 'package:monito/Helper/IntExtensions.dart';

class GridButton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final String asset;
  final String title;
  final VoidCallback onPressed;

  GridButton({@required this.width, @required this.height, @required this.borderRadius, @required this.asset, @required this.title, @required this.onPressed});

  @override
  _GridButtonState createState() => _GridButtonState();
}

class _GridButtonState extends State<GridButton> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Material(
        color: Color(0xFF1D2939),
        child: InkWell(
          onTap: () {
            widget.onPressed();
          },
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 30,
                  width: 30,
                  margin: EdgeInsets.only(bottom: 4, top: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Image.asset(
                    widget.asset,
                    color: Colors.white,
                  ),
                ),
                10.height,
                Text(
                  widget.title,
                  style: TextStyle(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
