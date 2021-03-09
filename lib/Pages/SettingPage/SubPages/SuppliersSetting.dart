import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Pages/SettingPage/Model/SupplierModel.dart';
import 'package:monito/Pages/SettingPage/Overlay/AddSupplierOverlay.dart';
import 'package:monito/Widgets/Loading.dart';

class SuppliersSetting extends StatefulWidget {
  @override
  _SuppliersSettingState createState() => _SuppliersSettingState();
}

class _SuppliersSettingState extends State<SuppliersSetting> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  bool _isError = false;
  bool _isLoading = false;
  bool _isInit = false;
  bool saveStatus = false;
  List<SupplierModel> suppliers = [];
  int maxCount = 10;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Timer(Duration(milliseconds: Constants.TransitionTime), () => _init());
  }

  _init() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    String url = Constants.URL + "api/setting/suppliers";
    var response = await HttpHelper.authGet(context, null, url, {});
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          for (var item in result['data']) {
            await _databaseProvider.insertOrUpdateSupplier(item['id'], item['name']);
            suppliers.add(SupplierModel.fromJson(item));
          }
          setState(() {
            _isInit = true;
            _isLoading = false;
          });
        }
      } else {
        _errorHandler();
      }
    }
  }

  _errorHandler() {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  _successAddSupplier(SupplierModel supplierModel){
    this.suppliers.add(supplierModel);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Supplier Setting"),
        backgroundColor: Constants.StatusBarColor,
        actions: [
          _isInit && suppliers.length <= 10
              ? IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).push(AddSupplierOverlay(successHandler: _successAddSupplier));
                  })
              : Container(),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: Constants.BackgroundColor,
          child: Stack(
            children: [
              _isError
                  ? Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("エラー!", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  : suppliers.length == 0
                      ? Positioned.fill(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "該当データがありません。\n Click `+` button to add",
                              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : Positioned.fill(
                          child: ListView.separated(
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: Text(suppliers[index].name),
                                );
                              },
                              separatorBuilder: (context, index) => Divider(color: Colors.transparent),
                              itemCount: suppliers.length),
                        ),
              _isLoading
                  ? Positioned.fill(
                      child: Container(color: Constants.BackgroundColor, child: Loading()),
                    )
                  : Container()
            ],
          ),
        ),
      ),
      floatingActionButton: saveStatus
          ? FloatingActionButton(
              child: Icon(Icons.save),
              onPressed: () {},
            )
          : null,
    );
  }
}
