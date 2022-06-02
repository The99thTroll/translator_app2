import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/firebaseCommunicator.dart';
import '../providers/canticle.dart';

class LoadedPoemTile extends StatefulWidget {
  final data;
  final reloadPoems;

  LoadedPoemTile({
    @required this.data,
    @required this.reloadPoems
  });

  @override
  _LoadedPoemTileState createState() => _LoadedPoemTileState();
}

class _LoadedPoemTileState extends State<LoadedPoemTile> {
  bool _textOpen = false;

  @override
  Widget build(BuildContext context) {
    var firebase = Provider.of<FirebaseCommunicator>(context);
    var canticle = Provider.of<Canticle>(context);
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
                      onPressed: () async {
                        canticle.clearAll();

                        canticle.setTranslator1(data[1]["translator1"]["name"]);
                        canticle.setTranslator2(data[1]["translator2"]["name"]);

                        var info = await canticle.getCanticles();
                        canticle.setCanticle(info[data[1]['canticleIndex']]);

                        canticle.setCanto(data[1]["cantoIndex"].toString());

                        canticle.updateBoxes(data[1]["boxData"]);
                        canticle.setVerses(data[1]["verses"]);

                        canticle.setVersion(data[1]['version']+1);
                        canticle.setLoaded(data[1]['title']);

                        Navigator.of(context).pop();
                      },
                      color: Color(0xFF48B100),
                      icon: Icon(
                        Icons.check,
                      )
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 115,
                      child: Row(
                            children: [
                              Container(
                                width: 90,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "Version ${data[1]["version"]}",
                                  )
                                ),
                              GestureDetector(
                                child: _textOpen
                                    ? Icon(Icons.keyboard_arrow_down)
                                    : Icon(Icons.keyboard_arrow_up),
                                onTap: (){
                                  setState(() {
                                    _textOpen = !_textOpen;
                                  });
                                },
                              ),
                            ],
                          ),
                    ),
                  ],
                ),
          )),
          if(_textOpen) Container(
            padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 4
            ),
            height: min(data[1]["verses"].length * 40.0 + 30, 250.0),
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
                              if(_textController.text.trim() != "") await firebase.addAnnotation(_textController.text, data[0], _textSentimentController.text, index);
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
                        children: List.generate(data[1]['annotations'][index].length, (subIndex){
                          if (subIndex != 0) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "\"${data[1]["annotations"][index][subIndex]['annotation']}\"",
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    GestureDetector(
                                      child: Icon(
                                        Icons.messenger,
                                        color: Colors.green,
                                        size: 15,
                                      ),

                                      onTap: () async {
                                        TextEditingController _textController = TextEditingController();
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

                                        await firebase.addNestedAnnotation(_textController.text, data[0], index, subIndex);
                                      },
                                    )
                                  ],
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "- ${data[1]["annotations"][index][subIndex]['username']}",
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[600]
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Column(
                                    children: data[1]['annotations'][index][subIndex].containsKey("subAnnotations")
                                      ? List.generate(data[1]['annotations'][index][subIndex]['subAnnotations'].length,
                                          (subSubIndex){
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                left: 15,
                                                top: 4,
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text(
                                                      "\"${data[1]["annotations"][index][subIndex]['subAnnotations'][subSubIndex]['annotation']}\"",
                                                      style: TextStyle(
                                                          fontStyle: FontStyle.italic,
                                                          fontSize: 12
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text(
                                                      "- ${data[1]["annotations"][index][subIndex]['subAnnotations'][subSubIndex]['username']}",
                                                      style: TextStyle(
                                                          fontStyle: FontStyle.italic,
                                                          color: Colors.grey[600],
                                                          fontSize: 12
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          })
                                      : []
                                  ),
                                ),
                                
                                if(subIndex != data[1]['annotations'][index].length-1) Divider(thickness: 1)
                              ],
                            );
                          }

                          return Container();
                        }),
                      ),
                    ),

                    Divider(thickness: 3)
                  ]
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
