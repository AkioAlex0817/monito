import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Helper/IntExtensions.dart';
import 'package:monito/Helper/LangHelper.dart';
import 'package:monito/Pages/PublishPage/Formatter/CurrencyInputFormatter.dart';
import 'package:monito/Widgets/LoadingButton.dart';

class TrackArchivePercentDialog extends StatefulWidget {
  final int archivePercent;

  TrackArchivePercentDialog({Key key, this.archivePercent}) : super(key: key);

  @override
  _TrackArchivePercentDialogState createState() => _TrackArchivePercentDialogState();
}

class _TrackArchivePercentDialogState extends State<TrackArchivePercentDialog> {
  final percentController = TextEditingController();
  FocusNode percentNode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    percentNode = FocusNode();
    percentNode.addListener(() {
      if (this.percentNode.hasFocus) {
        if (this.percentController.text.length > 0) {
          this.percentController.selection = TextSelection(baseOffset: 0, extentOffset: this.percentController.text.length);
        }
      }
    });
    setState(() {
      percentController.text = widget.archivePercent.toString();
    });
  }

  @override
  void dispose() {
    percentController?.dispose();
    percentNode?.dispose();
    super.dispose();
  }

  _save() async {
    if (_isLoading) return;
    String percent = percentController.text.trim();
    if (percent.isEmpty) {
      Helper.showToast("上昇率を入力してください。", false);
      return;
    }
    if (int.parse(percent) > 100) {
      Helper.showToast("上昇率は100%以下の値を入力してください。", false);
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _isLoading = true;
    });
    String url = Constants.URL + "api/setting/price_archive_percent";
    var response = await HttpHelper.authPost(context, url, {'value': percent}, {}, false);
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          Helper.showToast(LangHelper.SUCCESS, true);
          Navigator.pop(context, percent);
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: new BoxDecoration(
          color: Constants.BackgroundColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(padding: EdgeInsets.all(4), alignment: Alignment.centerRight, child: Icon(Icons.close, color: Colors.black)),
            ),
            Text("上昇率(%)", style: TextStyle(color: Colors.black, fontSize: 20)),
            16.height,
            TextFormField(
              controller: percentController,
              focusNode: percentNode,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(4, 8, 4, 8),
                hintText: '上昇率を入力してください。',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 0.0)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 0.0)),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
              style: TextStyle(color: Colors.black),
            ),
            30.height,
            SizedBox(
              height: 40,
              child: LoadingButton(
                color: Constants.ButtonColor,
                disabled: _isLoading,
                loading: _isLoading,
                title: "保存",
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
            16.height,
          ],
        ),
      ),
    );
  }
}
