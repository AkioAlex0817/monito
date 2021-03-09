import 'package:flutter/material.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Pages/SettingPage/Model/SupplierModel.dart';

import 'OverlayWidget/AddSupplierWidget.dart';

typedef SuccessHandler = Function(SupplierModel);

class AddSupplierOverlay extends ModalRoute<void> {
  final SuccessHandler successHandler;

  AddSupplierOverlay({@required this.successHandler});

  @override
  Color get barrierColor => Colors.black54.withOpacity(0.5);

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            height: screenSize.height * 0.3,
            width: screenSize.width * 0.8,
            child: Container(
              decoration: BoxDecoration(color: Constants.BackgroundColor, border: Border.all(color: Colors.white, width: 1, style: BorderStyle.solid), borderRadius: BorderRadius.circular(10)),
              child: AddSupplierWidget(
                successHandler: (value) {
                  _success(context, value);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: Constants.TransitionTime);

  _success(BuildContext context, SupplierModel supplierModel) {
    Navigator.pop(context);
    successHandler(supplierModel);
  }
}
