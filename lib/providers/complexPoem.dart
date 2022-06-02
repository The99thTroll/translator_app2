import 'package:flutter/material.dart';

class ComplexPoem with ChangeNotifier{
  List _pickedTranslators = ["Mark Musa","Mark Musa","Mark Musa","Mark Musa",
    "Mark Musa","Mark Musa","Mark Musa","Mark Musa","Mark Musa"];
  List _pickedTranslatorsIndex = [0,0,0,0,0,0,0,0,0];
  List _translatedValues = ['','','','','','','','',''];

  List get pickedTranslators {
    return _pickedTranslators;
  }

  List get pickedTranslatorsIndex {
    return _pickedTranslatorsIndex;
  }

  List get translatedValues {
    return _translatedValues;
  }

  setTranslator(int tileIndex, dynamic data, int translatorIndex){
    _pickedTranslators[tileIndex] = data;
    _pickedTranslatorsIndex[tileIndex] = translatorIndex;
    notifyListeners();
  }

  setValues(int index, String text){
    _translatedValues[index] = text;
    notifyListeners();
  }

  replaceValues({List pickedTranslatorsN, List pickedTranslatorIndexN, List translatedValuesN}){
    _pickedTranslators = pickedTranslatorsN;
    _pickedTranslatorsIndex = pickedTranslatorIndexN;
    _translatedValues = translatedValuesN;
    notifyListeners();
  }
}