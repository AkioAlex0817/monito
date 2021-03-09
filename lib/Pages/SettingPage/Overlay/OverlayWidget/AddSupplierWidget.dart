import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Helper/LangHelper.dart';
import 'package:monito/Pages/SettingPage/Model/SupplierModel.dart';
import 'package:monito/Widgets/LoadingButton.dart';

typedef SuccessHandler = Function(SupplierModel);

class AddSupplierWidget extends StatefulWidget {
  final SuccessHandler successHandler;

  AddSupplierWidget({@required this.successHandler});

  @override
  _AddSupplierWidgetState createState() => _AddSupplierWidgetState();
}

class _AddSupplierWidgetState extends State<AddSupplierWidget> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  TextEditingController _supplierController = new TextEditingController();
  FocusNode _supplierNode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _supplierController?.dispose();
    _supplierNode?.dispose();
    super.dispose();
  }

  _save() async {
    if (_isLoading) return;
    String supplierName = _supplierController.text.trim();
    if (supplierName.isEmpty) {
      Helper.showToast("Please insert Supplier name", false);
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _isLoading = true;
    });
    String url = Constants.URL + "api/setting/supplier/store";
    var response = await HttpHelper.authPost(context, url, {'value': supplierName}, {}, false);
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          SupplierModel supplierModel = SupplierModel.fromJson(result['data']);
          await _databaseProvider.insertOrUpdateSupplier(supplierModel.id, supplierModel.name);
          widget.successHandler(supplierModel);
        } else {
          Helper.showToast(LangHelper.FAILED, false);
        }
      } else {
        Helper.showToast(LangHelper.FAILED, false);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                "Add new supplier",
                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: TextFormField(
                controller: _supplierController,
                focusNode: _supplierNode,
                style: TextStyle(fontSize: 18.0, color: Colors.black),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                    hintText: "Supplier Name",
                    hintStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5))),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: Center(
                child: LoadingButton(
                  color: Constants.ButtonColor,
                  disabled: _isLoading,
                  loading: _isLoading,
                  title: "Add",
                  fontColor: Colors.white,
                  fontSize: 15,
                  loadingColor: Colors.black,
                  loadingSize: 20,
                  borderRadius: 10,
                  onPressed: () {
                    _save();
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
