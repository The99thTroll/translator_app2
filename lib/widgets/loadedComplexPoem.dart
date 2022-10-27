import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:translator_app/providers/complexPoem.dart';

import '../providers/firebaseCommunicator.dart';
import '../providers/canticle.dart';

import 'package:graphite/core/matrix.dart';
import 'package:graphite/core/typings.dart';
import 'package:graphite/graphite.dart';

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
  bool _breakdown = false;

  List graphData = [];

  static const presetBasic =
      '[{"id":"A","next":["B"]},{"id":"B","next":["C","D","E"]},'
      '{"id":"C","next":["F"]},{"id":"D","next":["J"]},{"id":"E","next":["J"]},'
      '{"id":"J","next":["I"]},{"id":"I","next":["H"]},{"id":"F","next":["K"]},'
      '{"id":"K","next":["L"]},{"id":"H","next":["L"]},{"id":"L","next":["P"]},'
      '{"id":"P","next":["M","N"]},{"id":"M","next":[]},{"id":"N","next":[]}]';

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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Based of ${data[1]["original"]}\n"
                        "Created by ${data[1]["userName"]}\n"
                        "${DateFormat('M/dd/yyyy').format(DateTime.parse(data[1]["postDate"]))}"),
                    TextButton(
                     onPressed: (){
                       
                       var tempMap = {};
                       graphData = [{"id": "Canto ${data[1]['cantoIndex']}", "next": []}, {"id": data[1]['original'], "next": ["Canto ${data[1]['cantoIndex']}"]},  {"id": data[1]['title'], "next": []}];

                       var elements = data[1]['verses'];
                       var sortedElementsDict = {};
                       var sortedElementsList = [];

                       var index = 0;
                       for(var item in elements){
                         if(sortedElementsDict[data[1]['translators'][index]] == null) {
                           sortedElementsDict[data[1]['translators'][index]] = [item];
                         }else{
                           sortedElementsDict[data[1]['translators'][index]].add(item);
                         }
                         index++;
                       }

                       for(var item in sortedElementsDict.entries){
                         sortedElementsList.add({
                           'verse': item.value,
                           'translator': item.key
                         });
                       }

                       if(sortedElementsDict['item'] == null){
                         print("item was found to be null!");
                       }

                       for (var item in sortedElementsList){
                         var translator = item['translator'];
                         for(var element in item['verse']){
                           tempMap[element] = {
                             "id": "$element",
                             "next": [translator],
                             "nextID": '$element'
                           };
                           graphData[0]['next'].add(element);
                         }
                       }

                       for(var item in data[1]['translators']){
                         if(tempMap[item] == null){
                           tempMap[item] = {
                             "id": "$item",
                             "next": [data[1]['title']]
                           };
                         }
                         index++;
                       }

                       for(var item in tempMap.values){
                         graphData.add(item);
                       }

                       showModalBottomSheet(context: context, builder: (ctx){
                         return DirectGraph(
                           list: nodeInputFromJson(json.encode(graphData)),
                           cellWidth: 160.0,
                           cellPadding: 24.0,
                           orientation: MatrixOrientation.Vertical,
                         );
                       });

                       // setState(() {
                       //   _open = false;
                       //   _breakdown = !_breakdown;
                       // });
                     },
                     child: Text(
                       "View Breakdown",
                       textAlign: TextAlign.start,
                       style: TextStyle(
                         fontWeight: FontWeight.bold,
                         color: Colors.blue,
                       ),
                     )
                    )
                  ],
                ),
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
                              _breakdown = false;
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
                                //
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
          ),
          if(_breakdown) Container(
            padding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 4
            ),
            height: 250,
            child: DirectGraph(
              list: nodeInputFromJson(json.encode(graphData)),
              cellWidth: 100.0,
              cellPadding: 12.0,
              orientation: MatrixOrientation.Vertical,
            ),
          )
        ],
      ),
    );
  }
}
