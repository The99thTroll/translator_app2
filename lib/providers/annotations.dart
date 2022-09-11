import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';

class Annotations with ChangeNotifier{
  List<List> _annotations = [['FILLER'],['FILLER'],['FILLER'],
    ['FILLER'],['FILLER'],['FILLER'],['FILLER'],['FILLER'],['FILLER']];

  List get annotations {
    return _annotations;
  }

  getAndUseData({context, index, username}) async {
    TextEditingController _textController = TextEditingController();
    TextEditingController _textSentimentController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey();

    await showModalBottomSheet(
        context: context,
        builder: (ctx){
          return Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(0),
                child: Container(
                  height: 130 + ((((_annotations[index].length-1)/2).round()) * 50.0),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        if(_annotations[index].length > 1)
                        Text(
                          "Annotations - Verse ${index+1}",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline
                          ),
                        ),

                        if(_annotations[index].length > 1)
                        Expanded(
                          child: Container(
                            height: (_annotations[index].length/2).floor() * 85.0,
                            child: GridView.builder(
                              itemCount: _annotations[index].length - 1,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5,
                                childAspectRatio: 12/2,
                                crossAxisCount: _annotations[index].length == 1
                                ? 1
                                : 2
                              ),
                              itemBuilder: (ctx, indexGiven){
                                var i = indexGiven + 1;
                                return Column(
                                  children: [
                                    Text(
                                      "${i}) \"${_annotations[index][i]['annotation']}\"",
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 15
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                        "- ${_annotations[index][i]['username']} [${
                                           DateTime.parse(_annotations[index][i]['time']).millisecondsSinceEpoch < DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch
                                          ? DateFormat.yMd().add_jm().format(DateTime.parse(_annotations[index][i]['time']))
                                          : DateFormat.jm().format(DateTime.parse(_annotations[index][i]['time']))
                                        }]",
                                        textAlign: TextAlign.right,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey
                                        )
                                    ),
                                    SizedBox(height: 5)
                                  ],
                                );
                              }
                            )
                          ),
                        ),

                        Text(
                          "Add Annotations",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline
                          ),
                        ),
                        Row(
                          children: [
                          Expanded(
                            child: TextFormField(
                            controller: _textController,
                            decoration: InputDecoration(labelText: 'Annotation'),
                            validator: (value) {
                              if (value.length == 0) {
                              return 'Please write an annotation!';
                              }
                              if (value.length < 12) {
                              return 'Your annotation is too short!';
                              }
                              return null;
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                            controller: _textSentimentController,
                            decoration: InputDecoration(labelText: 'Sentiment - Describe tone of annotation'),
                              validator: (value) {
                              if (value.length == 0) {
                              return 'Please write a sentiment!';
                              }
                              return null;
                              },
                            ),
                          ),
                            Container(
                              margin: EdgeInsets.only(
                                  left: 32,
                                  right: 8
                              ),
                              child: ElevatedButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(
                                        fontSize: 16
                                    ),
                                  )
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
          );
        }
    );

    if (_textController.text.isNotEmpty) {
      var hashableData = {
        'annotation': {
          'data': _textController.text,
          'sentiment': _textSentimentController.text
        },
        'username': username,
        'time': DateTime.now().toIso8601String(),
        "previousHash": 0
      };

      var hash = sha256.convert(utf8.encode(hashableData.toString()));



      print(hash.toString());

      _annotations[index].add({
        'annotation': {
          'data': _textController.text,
          'sentiment': _textSentimentController.text,
        },
        'username': username,
        'time': DateTime.now().toIso8601String(),
        "previousHash": 0,
        "currentHash": hash.toString()
      });
    }

    notifyListeners();
  }

  clear(){
    _annotations = [['FILLER'],['FILLER'],['FILLER'],
      ['FILLER'],['FILLER'],['FILLER'],['FILLER'],['FILLER'],['FILLER']];
    notifyListeners();
  }
}