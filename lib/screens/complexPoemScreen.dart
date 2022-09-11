import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/providers/annotations.dart';
import 'package:translator_app/providers/complexPoem.dart';

import '../providers/canticle.dart';
import '../providers/firebaseCommunicator.dart';

import '../widgets/containedElevatedButton.dart';
import '../widgets/dropDown.dart';

class ComplexPoemScreen extends StatefulWidget {
  static const routeName = '/complex';

  @override
  _ComplexPoemScreenState createState() => _ComplexPoemScreenState();
}

class _ComplexPoemScreenState extends State<ComplexPoemScreen> {
  @override
  Widget build(BuildContext context) {
    double sWidth = MediaQuery.of(context).size.width;
    double sHeight = MediaQuery.of(context).size.height;

    var canticle = Provider.of<Canticle>(context);
    var complexPoem = Provider.of<ComplexPoem>(context);
    var firebase = Provider.of<FirebaseCommunicator>(context);

    var _textController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey();

    return Scaffold(
      appBar: AppBar(
          title: Text("Complex Poem Creation: ${
              canticle.loadedName.isNotEmpty
                  ? canticle.loadedName
                  : "${canticle.currentCanticle} - ${canticle.currentCanto}"
          }"),
        backgroundColor: Theme.of(context).primaryColorDark,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: FutureBuilder(
                      future: canticle.getTranslators(),
                      builder: (ctx, snapshot) {
                        List<String> dropDownData = List<String>.from(snapshot.data);
                        return FutureBuilder(
                            future: canticle.getVerseArray(
                                0, canticle.currentCanto),
                            builder: (ctx, snapshot) {
                              if (!snapshot.hasData) {
                                if (int.parse(canticle.currentCanto) == 1 &&
                                    canticle.canticleIndex == 1) {
                                  return Text("e");
                                }
                                return Center(child: CircularProgressIndicator());
                              } else {
                                var data = snapshot.data;
                                return ListView.builder(
                                    itemCount: 9,
                                    itemBuilder: (ctx, i) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(data[i]),
                                                DropDown(
                                                  options: dropDownData,
                                                  cWidth: 150,
                                                  selectedOption: canticle.complexLoaded
                                                    ? complexPoem.pickedTranslators[i]
                                                    : dropDownData[0],
                                                  update: (picked) async {
                                                    complexPoem.setTranslator(i, picked, dropDownData.indexOf(picked));
                                                    var x = await canticle.getVerseArray(complexPoem.pickedTranslatorsIndex[i]+1, canticle.currentCanto);
                                                    complexPoem.setValues(i, x[i]);
                                                  }
                                                ),
                                              ],
                                            ),
                                          ),

                                          SizedBox(width: 50),

                                          Container(
                                              width: 225,
                                              child: Row(
                                                children: [
                                                  Stack(
                                                    children: [
                                                      InkWell(
                                                        customBorder: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        onTap: (){
                                                          Provider.of<Annotations>(context).getAndUseData(
                                                            context: context,
                                                            index: i,
                                                            username: firebase.userName
                                                          );
                                                        },
                                                        child: Icon(
                                                          Icons.add_circle,
                                                          color: Colors.green[600],
                                                        ),
                                                      ),

                                                      if(Provider.of<Annotations>(context).annotations[i].length > 1)
                                                        Container(
                                                          width: 10,
                                                          height: 10,
                                                          decoration: BoxDecoration(
                                                            color: Colors.yellow[700],
                                                            borderRadius: BorderRadius.circular(90.0)
                                                          ),
                                                        )
                                                    ],
                                                  ),

                                                  SizedBox(width: 7.5),

                                                  Expanded(
                                                    child: Text(
                                                      complexPoem.translatedValues[i],
                                                      overflow: TextOverflow.clip,
                                                    ),
                                                  ),
                                                ],
                                              )
                                          ),
                                        ],

                                      );
                                    }
                                );
                              }
                            }
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text("Save"),
                onPressed: () async {
                  showModalBottomSheet(
                      context: context,
                      builder: (ctx){
                        return Form(
                            key: _formKey,
                            child: Padding(
                              padding: EdgeInsets.all(0),
                              child: Container(
                                height: 125,
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
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 32,
                                                right: 8
                                            ),
                                            child: ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.of(context).pop();

                                                  print(Provider.of<Annotations>(context).annotations);

                                                  // try {
                                                    await firebase.saveComplexPoem(
                                                        data: complexPoem.translatedValues,
                                                        translators: complexPoem.pickedTranslators,
                                                        translatorIndex: complexPoem.pickedTranslatorsIndex,
                                                        original: canticle.poemVersion > 1
                                                            ? canticle.loadedName
                                                            : "${canticle.currentCanticle} - ${canticle.currentCanto}",
                                                        canticleIndex: canticle.canticleIndex,
                                                        cantoIndex: int.parse(canticle.currentCanto),
                                                        version: canticle.poemVersion,
                                                        title: _textController.text,
                                                        annotations: Provider.of<Annotations>(context).annotations
                                                    );

                                                    showDialog(
                                                      context: context,
                                                      builder: (ctx){
                                                        return AlertDialog(
                                                          title: Text('Success!'),
                                                          content: Text('Your poem ${_textController.text} was saved!'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: (){
                                                                Navigator.of(context).pop();
                                                              },
                                                              child: Text("Okay")
                                                            )
                                                          ],
                                                        );
                                                      }
                                                    );
                                                  // } catch (error) {
                                                  //   print(error);
                                                  //   showDialog(
                                                  //       context: context,
                                                  //       builder: (ctx){
                                                  //         return AlertDialog(
                                                  //           title: Text('Oops!'),
                                                  //           content: Text('There was an error saving ${_textController.text}!'),
                                                  //           actions: [
                                                  //             TextButton(
                                                  //                 onPressed: (){
                                                  //                   Navigator.of(context).pop();
                                                  //                 },
                                                  //                 child: Text("Okay")
                                                  //             )
                                                  //           ]
                                                  //         );
                                                  //       }
                                                  //   );
                                                  // }
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
                },
              ),
            ],
          ),
          SizedBox(height: 10)
        ],
      ),
    );
  }
}