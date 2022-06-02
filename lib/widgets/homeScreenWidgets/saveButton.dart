import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/providers/annotations.dart';

import '../../providers/canticle.dart';
import '../../providers/firebaseCommunicator.dart';

import '../containedElevatedButton.dart';

class SaveButton extends StatefulWidget {
  @override
  State<SaveButton> createState() => _SaveButtonState();

  SaveButton();
}

class _SaveButtonState extends State<SaveButton> {
  String sentiment = "Neutral";

  @override
  Widget build(BuildContext context) {
    double sWidth = MediaQuery.of(context).size.width;

    var _textController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey();

    var canticle = Provider.of<Canticle>(context);
    var firebase = Provider.of<FirebaseCommunicator>(context);
    var annotations = Provider.of<Annotations>(context);

    Future<void> _submit() async {
      if (!_formKey.currentState.validate()) {
        return;
      }
      _formKey.currentState.save();
      Navigator.of(context).pop();

      try {
        await firebase.savePoem(
            data: canticle.verseData["VerseData"],
            title: _textController.text,
            original: canticle.poemVersion > 1
              ? canticle.loadedName
              : "${canticle.currentCanticle} - ${canticle.currentCanto}",
            canticleIndex: canticle.canticleIndex,
            cantoIndex: int.parse(canticle.currentCanto),
            translators: [
              [canticle.translator1, canticle.translator1Index],
              [canticle.translator2, canticle.translator2Index]
            ],
            boxes: canticle.verseData['BoxData'],
            version: canticle.poemVersion,
            annotations: annotations.annotations
        );
        Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Poem Successfully Saved!",
              ),
              duration: Duration(seconds: 2),
            )
        );
      } catch (error) {
        Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "An error occurred while saving your poem!",
              ),
              duration: Duration(seconds: 2),
            )
        );
      }
    }

    return ContainedElevatedButton(
        width: sWidth/6.25,
        function: () async {

          showModalBottomSheet(
              context: context,
              builder: (ctx){
                return Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.all(0),
                    child: Container(
                      height: 114,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text(
                              "Title Your Poem",
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
                                    decoration: InputDecoration(labelText: 'Poem Title'),
                                    validator: (value) {
                                      if (value.length < 4) {
                                        return 'Title is too short!';
                                      }
                                      if (value.length > 20) {
                                        return 'Title is too long!';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 15),
                                DropdownButton(
                                  value: sentiment,
                                    items: [
                                      DropdownMenuItem(
                                        child: Text('Positive'),
                                        value: 'Positive',
                                      ),
                                      DropdownMenuItem(
                                        child: Text('Neutral'),
                                        value: 'Neutral',
                                      ),
                                      DropdownMenuItem(
                                        child: Text('Negative'),
                                        value: 'Negative',
                                      )
                                    ],
                                    onChanged: (val){
                                    print(val);
                                      setState(() {
                                        sentiment = val;
                                      });
                                    }
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                    left: 32,
                                    right: 8
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _submit,
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
        },
        label: "Save"
    );
  }
}
