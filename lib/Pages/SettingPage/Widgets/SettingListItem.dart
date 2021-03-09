import 'package:flutter/material.dart';
import 'package:monito/Helper/Constants.dart';

class SettingListItem extends StatelessWidget {
  String menuTitle;
  VoidCallback onPressed;
  Widget icon;

  SettingListItem({@required this.menuTitle, @required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onPressed();
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Constants.PrimaryColor))),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              menuTitle,
              style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            icon == null ? SizedBox(
              width: 10,
              child: Icon(Icons.keyboard_arrow_right, color: Colors.black),
            ) : icon
          ],
        ),
      ),
    );
  }
}
