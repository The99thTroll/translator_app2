import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:translator_app/providers/complexPoem.dart';

import '../providers/firebaseCommunicator.dart';
import '../providers/canticle.dart';

class LoadedComplexPoemTile extends StatefulWidget {
  final data;

  LoadedComplexPoemTile({
    @required this.data,
  });

  @override
  _LoadedPoemTileState createState() => _LoadedPoemTileState();
}

class _LoadedPoemTileState extends State<LoadedComplexPoemTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    var firebase = Provider.of<FirebaseCommunicator>(context);
    var canticle = Provider.of<Canticle>(context);
    var complex = Provider.of<ComplexPoem>(context);
    final data = widget.data;

    return Card(
      elevation: 5,
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(
                  data[1]["title"],
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text("Based of ${data[1]["original"]}\n"
                    "Created by ${data[1]["userName"]}\n"
                    "${DateFormat('M/dd/yyyy').format(DateTime.parse(data[1]["postDate"]))}"),
                leading: Transform.scale(
                  scale: 1.2,
                  child: IconButton(
                      onPressed: () async{
                        canticle.clearAll();

                        var info = await canticle.getCanticles();
                        canticle.setCanticle(info[data[1]['canticleIndex']]);

                        canticle.setCanto(data[1]["cantoIndex"].toString());

                        canticle.setVersion(data[1]['version']+1);
                        canticle.setLoaded(data[1]['title']);

                        canticle.toggleComplexLoaded(true);

                        complex.replaceValues(
                          pickedTranslatorsN: data[1]['translators'],
                          pickedTranslatorIndexN: data[1]['translatorIndex'],
                          translatedValuesN: data[1]['verses']
                        );
                        
                        if (canticle.viewMode == false) {
                          canticle.toggleViewMode();
                        }

                        Navigator.of(context).pop();
                      },
                      color: Color(0xFF48B100),
                      icon: Icon(
                        Icons.check,
                      )
                  ),
                ),
                trailing: Container(
                  width: 115,
                  child: Row(
                    children: [
                      Container(
                          width: 75,
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Version ${data[1]["version"]}",
                          )
                      ),
                      IconButton(
                        icon: _open
                            ? Icon(Icons.keyboard_arrow_down)
                            : Icon(Icons.keyboard_arrow_up),
                        onPressed: (){
                          if (mounted == true) {
                            setState(() {
                              _open = !_open;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )),
          if(_open) Container(
            padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 4
            ),
            height: min(data[1]["verses"].length * 20.0 + 30, 200.0),
            child: ListView.builder(
              itemCount: data[1]["verses"].length,
              itemBuilder: (ctx, index){
                return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 5),
                            child: GestureDetector(
                              child: Icon(
                                Icons.add,
                                color: Colors.green,
                              ),

                              onTap: () async {
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
                                              height: 100,
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "Add Annotation",
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

                                                        TextFormField(
                                                          controller: _textSentimentController,
                                                          decoration: InputDecoration(labelText: 'Sentiment - Describe tone of annotation'),
                                                          validator: (value) {
                                                            if (value.length == 0) {
                                                              return 'Please write a sentiment!';
                                                            }
                                                            return null;
                                                          },
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

                                await firebase.addAnnotation(_textController.text, data[0], _textSentimentController, index);
                              },
                            ),
                          ),
                          Flexible(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                "Verse ${index+1}: ${data[1]["verses"][index]}",
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        child: Column(
                          children: List.generate(data[1]['annotations'][index].length-1, (subIndex){
                            return Column(
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "\"${data[1]["annotations"][index][subIndex+1]['annotation']}\"",
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "- ${data[1]["annotations"][index][subIndex+1]['username']}",
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[600]
                                    ),
                                  ),
                                ),
                                if(subIndex != data[1]['annotations'][index].length-2) Divider(thickness: 1)
                              ],
                            );
                          }),
                        ),
                      ),
                      Divider(thickness: 3)
                    ]
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
