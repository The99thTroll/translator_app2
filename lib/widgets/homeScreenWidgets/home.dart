import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/canticle.dart';
import '../../providers/textFieldManager.dart';
import '../../providers/firebaseCommunicator.dart';

import 'operations.dart';
import 'textFields.dart';
import 'pageSelectButtons.dart';
import 'composeButton.dart';
import 'saveButton.dart';

import '../containedElevatedButton.dart';
import '../dropDown.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double sWidth = MediaQuery.of(context).size.width;
    double sHeight = MediaQuery.of(context).size.height;

    var canticle = Provider.of<Canticle>(context);
    var manager = Provider.of<TextFieldManager>(context);
    var firebase = Provider.of<FirebaseCommunicator>(context);

    void setTextFields(){
      manager.setField(0, canticle.getVerse(0, canticle.currentCanto));
      manager.setField(1, canticle.getVerse(canticle.translator1Index+1, canticle.currentCanto));
      manager.setField(2, canticle.getVerse(canticle.translator2Index+1, canticle.currentCanto));
    }

    void authorCheck(){
      if(canticle.translator1Index == canticle.translator2Index){
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('WARNING'),
            content: Text("You have selected the same translator for both options. Please make sure that this is what you want."),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
    }

    return Container(
      height: sHeight,
      padding: const EdgeInsets.only(top: 8),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFields(),
            SizedBox(height: 7.5),
            PageSelectButtons(),
            Container(
              margin: EdgeInsets.only(
                  top: 5,
                  bottom: 10
              ),
              height: 10,
              width: double.infinity,
              color: Theme.of(context).primaryColorDark,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Operations(),
                Column(
                  children: <Widget>[
                    Text(
                      "Canticle",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    FutureBuilder<dynamic>(
                        future: canticle.getCanticles(), // a previously-obtained Future<String> or null
                        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasData) {
                            List<String> retrievedData = snapshot.data.cast<String>();
                            return DropdownButton<String>(
                              value: canticle.currentCanticle,
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle(color: Theme.of(context).primaryColor),
                              underline: Container(
                                height: 2,
                                color: Theme.of(context).primaryColorLight,
                              ),
                              onChanged: (String newValue) {
                                canticle.setCanticle(newValue);
                                setTextFields();                              },
                              items: retrievedData.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value)
                                );
                              }).toList(),
                            );
                          }else{
                            return CircularProgressIndicator();
                          }
                        }
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      "Canto",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    FutureBuilder<dynamic>(
                        future: canticle.getCantos(), // a previously-obtained Future<String> or null
                        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasData) {
                            List<String> retrievedData = snapshot.data.cast<String>();
                            return Container(
                              child: DropdownButton<String>(
                                value: canticle.currentCanto,
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(color: Theme.of(context).primaryColor),
                                underline: Container(
                                  height: 2,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                                onChanged: (String newValue) {
                                  canticle.setCanto(newValue);
                                  setTextFields();                              },
                                items: retrievedData.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value)
                                  );
                                }).toList(),
                              ),
                            );
                          }else{
                            return CircularProgressIndicator();
                          }
                        }
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      "Translator 1",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    FutureBuilder<dynamic>(
                        future: canticle.getTranslators(), // a previously-obtained Future<String> or null
                        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasData) {
                            List<String> retrievedData = snapshot.data.cast<String>();
                            return Container(
                              width: 150,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: canticle.translator1,
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(color: Theme.of(context).primaryColor),
                                underline: Container(
                                  height: 2,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                                onChanged: (String newValue) {
                                  canticle.setTranslator1(newValue);
                                  canticle.getVerse(canticle.translator1Index+1, canticle.currentCanto);
                                  setTextFields();
                                  authorCheck();
                                 },
                                items: retrievedData.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value)
                                  );
                                }).toList(),
                              ),
                            );
                          }else{
                            return CircularProgressIndicator();
                          }
                        }
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      "Translator 2",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    FutureBuilder<dynamic>(
                        future: canticle.getTranslators(), // a previously-obtained Future<String> or null
                        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasData) {
                            List<String> retrievedData = snapshot.data.cast<String>();
                            return Container(
                              width: 150,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: canticle.translator2,
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(color: Theme.of(context).primaryColor),
                                underline: Container(
                                  height: 2,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                                onChanged: (String newValue) {
                                  canticle.setTranslator2(newValue);
                                  canticle.getVerse(canticle.translator2Index+1, canticle.currentCanto);
                                  setTextFields();
                                  authorCheck();
                                },
                                items: retrievedData.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value)
                                  );
                                }).toList(),
                              ),
                            );
                          }else{
                            return CircularProgressIndicator();
                          }
                        }
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      "Current User",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 100,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        border: Border.all(
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                          firebase.userName
                      ),
                    )
                  ],
                ),
              ],
            ),
            Container(
                  height: sHeight/6.5,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ContainedElevatedButton(
                          width: sWidth/6.25,
                          function: canticle.viewMode == true
                          ? null
                          : (){
                            canticle.toggleViewMode();
                          },
                          label: "View"
                      ),
                      ComposeButton(sWidth/6.25),
                      SaveButton(),
                      ContainedElevatedButton(
                          width: sWidth/6,
                          function: null,
                          label: "Provenate"
                      ),
                      ContainedElevatedButton(
                          width: sWidth/6.25,
                          function: null,
                          label: "Annotate"
                      ),
                      ContainedElevatedButton(
                          width: sWidth/6.25,
                          function: (){
                            canticle.clearAll();
                            firebase.logout();
                          },
                          label: "Exit"
                      )
                    ],
                  )
              ),
          ],
        ),
      ),
    );
  }
}
