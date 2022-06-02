import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';

class Canticle with ChangeNotifier{
  String _currentCanticle = "Inferno";
  String _currentCanto = "1";
  String _translator1 = "Mark Musa";
  String _translator2 = "Allen Mandelbaum";
  List _allCanticles;
  List _allTranslators;
  int canticleIndex = 0;
  int translator1Index = 0;
  int translator2Index = 1;
  List translatedVerses = [];
  int poemVersion = 1;
  String loadedName = '';
  bool complexLoaded = false;

  Map verseData = {
    "BoxData": [[],[]],
    "VerseData": [],
  };
  bool viewMode = true;

  String get currentCanticle {
    return _currentCanticle;
  }

  String get currentCanto {
    return _currentCanto;
  }

  String get translator1 {
    return _translator1;
  }

  String get translator2 {
    return _translator2;
  }

  Future<String> _getJson() {
    return rootBundle.loadString("assets/Dante1.json");
  }

  getCanticles() async {
    var data = json.decode(await _getJson());
    var canticles = [];
    for(var i = 0; i < data["DivineComedy"][0]["Text"][0]["Canticles"].length; i++){
      canticles.add(data["DivineComedy"][0]["Text"][0]["Canticles"][i]["CanticleTitle"]);
    }
    _setCanticles(canticles);
    return canticles;
  }

  _setCanticles(value){
    _allCanticles = value;
  }

  getCantos() async {
    var data = json.decode(await _getJson());
    var cantos = [];
    for(var x = 0; x < data["DivineComedy"][0]["Text"][0]["Canticles"][canticleIndex]["Cantos"].length; x++){
      cantos.add("${x+1}");
    }
    return cantos;
  }

  getTranslators() async {
    var data = json.decode(await _getJson());
    var translators = [];
    for(var i = 1; i < data["DivineComedy"].length; i++){
      translators.add(data["DivineComedy"][i]["Author"]);
    }
    _allTranslators = translators;
    return translators;
  }

  getVerse(int authorIndex, String verseIndex) async {
    var list1 = [];
    var list2 = [];
    var list3 = [];

    var data = json.decode(await _getJson());
    var verses = "";
    var count = 0;
    for(var i = 0; i < data["DivineComedy"][authorIndex]["Text"][0]["Canticles"][canticleIndex]["Cantos"][int.parse(_currentCanto)-1]["Verses"].length; i++){
      if (verses != "") {
        verses += "\n\n${data["DivineComedy"][authorIndex]["Text"][0]["Canticles"][canticleIndex]["Cantos"][int.parse(_currentCanto)-1]["Verses"][i]["VerseText"]}";
      }else{
        verses += data["DivineComedy"][authorIndex]["Text"][0]["Canticles"][canticleIndex]["Cantos"][int.parse(_currentCanto)-1]["Verses"][i]["VerseText"];
      }
      count++;
    }

    if (verseData["BoxData"][0].length == 0) {
      if(count > 9){
        count = 9;
      }
      for(var x = 0; x < count; x++){
        list1.add(true);
        list2.add(false);
        list3.add(data["DivineComedy"][translator1Index+1]["Text"][0]["Canticles"][canticleIndex]["Cantos"][int.parse(_currentCanto)-1]["Verses"][x]["VerseText"]);
      }
    }else{
      list1 = verseData["BoxData"][0];
      list2 = verseData["BoxData"][1];
      for(var x = 0; x < verseData["VerseData"].length; x++){
        if(verseData["BoxData"][0][x] == true){
          list3.add(data["DivineComedy"][translator1Index+1]["Text"][0]["Canticles"][canticleIndex]["Cantos"][int.parse(_currentCanto)-1]["Verses"][x]["VerseText"]);
        }else{
          list3.add(data["DivineComedy"][translator2Index+1]["Text"][0]["Canticles"][canticleIndex]["Cantos"][int.parse(_currentCanto)-1]["Verses"][x]["VerseText"]);
        }
      }
    }

    verseData = {
      "BoxData": [list1,list2],
      "VerseData": list3,
    };

    return verses;
  }

  getVerseArray(int authorIndex, String verseIndex) async {
    var list1 = [];
    var list2 = [];
    var list3 = [];

    var data = json.decode(await _getJson());
    var verses = [];
    for(var i = 0; i < data["DivineComedy"][authorIndex]["Text"][0]["Canticles"][canticleIndex]["Cantos"][int.parse(_currentCanto)-1]["Verses"].length; i++){
      verses.add(data["DivineComedy"][authorIndex]["Text"][0]["Canticles"][canticleIndex]["Cantos"][int.parse(_currentCanto)-1]["Verses"][i]["VerseText"]);
    }

    if (verseData["BoxData"][0].length == 0) {
      for(var x = 0; x < verses.length; x++){
        list1.add(true);
        list2.add(false);
        list3.add(data["DivineComedy"][translator1Index+1]["Text"][0]["Canticles"][canticleIndex]["Cantos"][int.parse(_currentCanto)-1]["Verses"][x]["VerseText"]);
      }
    }else{
      list1 = verseData["BoxData"][0];
      list2 = verseData["BoxData"][1];
      for(var x = 0; x < verseData["VerseData"].length; x++){
        if(verseData["BoxData"][0][x] == true){
          list3.add(data["DivineComedy"][translator1Index+1]["Text"][0]["Canticles"][canticleIndex]["Cantos"][int.parse(_currentCanto)-1]["Verses"][x]["VerseText"]);
        }else{
          list3.add(data["DivineComedy"][translator2Index+1]["Text"][0]["Canticles"][canticleIndex]["Cantos"][int.parse(_currentCanto)-1]["Verses"][x]["VerseText"]);
        }
      }
    }

    verseData = {
      "BoxData": [list1,list2],
      "VerseData": list3,
    };
    _updateVerses();
    return verses;
  }

  setCanticle(String value){
    verseData = {
      "BoxData": [[],[]],
      "VerseData": [],
    };
    translatedVerses = [];
    _currentCanticle = value;
    _currentCanto = "1";
    canticleIndex = _allCanticles.indexOf(value);
    notifyListeners();
  }

  setTranslator1(String value){
    _translator1 = value;
    translator1Index = _allTranslators.indexOf(value);
    notifyListeners();
  }

  setTranslator2(String value){
    _translator2 = value;
    translator2Index = _allTranslators.indexOf(value);
    notifyListeners();
  }

  setCanto(String value){
    verseData = {
      "BoxData": [[],[]],
      "VerseData": [],
    };
    translatedVerses = [];

    _currentCanto = value;
    notifyListeners();
  }

  toggleViewMode(){
    viewMode = !viewMode;
    notifyListeners();
  }

  _updateVerses(){
    var verses = [];
    var suffix = "";
    for(var x = 0; x < verseData["VerseData"].length; x++){
      if(x == verseData["VerseData"].length - 1){
        suffix = "";
      }else{
        suffix = "\n\n";
      }

      if (verseData["VerseData"][x] != "") {
        verses.add("${verseData["VerseData"][x]}$suffix");
      }else{
        verses.add("\n\n");
        verses.add(" \n");
      }
    }

    translatedVerses = verses;
    notifyListeners();
  }

  setData({int listIndex, int itemIndex, String text}){
    verseData["VerseData"][itemIndex] = text;

    if(listIndex == 0){
      if(verseData["BoxData"][1][itemIndex] == true){
        verseData["BoxData"][0][itemIndex] = true;
        verseData["BoxData"][1][itemIndex] = false;
      }else{
        verseData["BoxData"][0][itemIndex] = true;
      }
    }else{
      if(verseData["BoxData"][0][itemIndex] == true){
        verseData["BoxData"][1][itemIndex] = true;
        verseData["BoxData"][0][itemIndex] = false;
      }else{
        verseData["BoxData"][1][itemIndex] = true;
      }
    }
    _updateVerses();
    notifyListeners();
  }

  clearAll([resetPage = true, resetOperation = true, resetVerse = true]){
    if(resetPage == true) {
      _currentCanticle = "Inferno";
      _currentCanto = "1";
    }

    if(resetOperation == true){
      viewMode = true;
    }

    if(resetVerse == true){
      verseData = {
        "BoxData": [[true, true, true, true, true, true, true, true, true],
          [false, false, false, false, false, false, false, false, false]],
        "VerseData": [],
      };
    }

    _translator1 = "Mark Musa";
    _translator2 = "Allen Mandelbaum";
    _allCanticles = [];
    _allTranslators = [];
    canticleIndex = 0;
    translator1Index = 0;
    translator2Index = 1;
    translatedVerses = [];
    poemVersion = 1;
    complexLoaded = false;
    loadedName = '';

    notifyListeners();
  }

  updateBoxes(input){
    verseData["BoxData"] = input;
    notifyListeners();
  }

  setVerses(input){
    verseData["VerseData"] = input;
    notifyListeners();
  }

  setVersion(input){
    poemVersion = input;
    notifyListeners();
  }

  setLoaded(input){
    loadedName = input;
    notifyListeners();
  }

  toggleComplexLoaded(bool state){
    complexLoaded = state;
    notifyListeners();
  }
}