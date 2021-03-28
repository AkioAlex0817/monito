import 'package:flutter/material.dart';
import 'package:monito/main.dart';

extension IntExtensions on int {
  Widget get height => SizedBox(height: this.toDouble());

  Widget get width => SizedBox(width: this.toDouble());

  String get formatter => this == -1 ? "-- " : currency.format(this);
}

extension StringExtensions on String {
  String get check => this == null ? "" : this;
}
