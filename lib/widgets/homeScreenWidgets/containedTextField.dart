import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/textFieldManager.dart';
import '../../providers/canticle.dart';

import 'verseSelector.dart';

class ContainedTextField extends StatelessWidget {
  final double width;
  final int lines;
  final String hintText;
  final int index;

  ContainedTextField({
    @required this.width,
    @required this.lines,
    @required this.hintText,
    @required this.index,
  });

  @override
  Widget build(BuildContext context) {
    var manager = Provider.of<TextFieldManager>(context);
    var canticle = Provider.of<Canticle>(context);
    var textController = TextEditingController();

    final fieldData = [canticle.getVerse(0, canticle.currentCanto), canticle.getVerse(canticle.translator1Index+1, canticle.currentCanto), canticle.getVerse(canticle.translator2Index+1, canticle.currentCanto), canticle.translatedVerses];

    if(!Provider.of<Canticle>(context).viewMode && (index == 2 || index == 3)) {
      return FutureBuilder<dynamic>(
          future: canticle.getVerseArray(
              index == 2 ? canticle.translator1Index+1 : canticle.translator2Index+1,
              canticle.currentCanto
          ),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            var retrievedData = snapshot.data;
            if (retrievedData is List) {
              if(retrievedData.length > 0){
                return VerseSelector(
                    index: index - 2,
                    width: width,
                    lines: lines,
                    data: retrievedData);
              }else{
                return Container(
                    width: width,
                    height: lines*21.666,
                    decoration: BoxDecoration(
                    border: Border.all(
                        width: 1,
                        color: Colors.grey
                      ),
                    borderRadius: BorderRadius.circular(5)
                  ),
                );
              }
            }else{
              return Container(
                width: width,
                height: lines*21.666,
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1,
                        color: Colors.grey
                    ),
                    borderRadius: BorderRadius.circular(5)
                ),
              );
            }
          }
      );
    }else if(index != 4) {
      return FutureBuilder<dynamic>(
          future: fieldData[index - 1],
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            var retrievedData = snapshot.data == null ? "" : snapshot.data.runtimeType == String ? snapshot.data : snapshot.data.cast<String>();
            textController.text = retrievedData.toString().replaceAll("[", "").replaceAll("]", "");
            return Container(
              width: width,
              child: TextField(
                readOnly: true,
                controller: textController,
                maxLines: lines,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: hintText
                ),
              ),
            );
          }
      );
    }else{
      var translatedVerses = canticle.translatedVerses;
      textController.text = translatedVerses.toString().replaceAll("[", "").replaceAll("]", "").replaceAll("\n, ", "\n").replaceAll("\n\n\n", "");
      return Container(
        width: width,
        child: TextField(
          readOnly: true,
          controller: textController,
          maxLines: lines,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: hintText
          ),
        ),
      );
    }
  }
}