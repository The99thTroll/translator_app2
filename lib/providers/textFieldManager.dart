import 'dart:convert';

import 'package:flutter/material.dart';

class TextFieldManager with ChangeNotifier{
  List _fieldData = ["","","",""];

  TextFieldManager(this._fieldData);

  List get fieldData {
    return _fieldData;
  }

  setField(int index, dynamic data){
    _fieldData[index] = data;
    notifyListeners();
  }
}