import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/widgets/loadedComplexPoem.dart';

import '../widgets/loadedPoemTile.dart';

import '../providers/canticle.dart';
import '../providers/firebaseCommunicator.dart';

import 'package:graphite/core/matrix.dart';
import 'package:graphite/graphite.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';
enum FilterOptions{
  Mine,
  All
}

enum SearchType{
  PoemName,
  AuthorName,
  PoemId
}

class SelectScreen extends StatefulWidget {
  static const routeName = '/select';

  @override
  _SelectScreenState createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  var _displayChoice = FilterOptions.All;
  var storedData;
  var filteredData;
  var keyword = "";
  var searchMode = "Poem Name";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_){
          _refreshPoems();
        });
  }

  void checkFilter(){
    var usableData = [];
    int start = DateTime.now().millisecondsSinceEpoch;

    for(var x in storedData){
      if(keyword != null && keyword != ""){
        if(searchMode == "Poem Name" && x[1]['title'].toLowerCase().startsWith(keyword.toLowerCase())){
          usableData.add(x);
        }else if(searchMode == "Author Name" && x[1]['userName'].toLowerCase().startsWith(keyword.toLowerCase())){
          usableData.add(x);
        }else if(searchMode == "Poem Id" && x[0].toLowerCase().startsWith(keyword.toLowerCase())){
          usableData.add(x);
        }else if(searchMode == "Verse"){
          for(var y in x[1]['verses']){
            if(y.toLowerCase().contains(keyword.toLowerCase())){
              usableData.add(x);
            }
          }
        }else if(searchMode == "Translator"){
          if(x[1]['translators'] == null){
            if(x[1]['translator1']['name'].toLowerCase().contains(keyword.toLowerCase())){
              usableData.add(x);
            }else if(x[1]['translator2']['name'].toLowerCase().contains(keyword.toLowerCase())){
              usableData.add(x);
            } else if(x[1]['translator2']['name'].toLowerCase().contains(keyword.toLowerCase())){
              usableData.add(x);
            }
          }else{
            for(var y in x[1]['translators']){
              if(y.toLowerCase().contains(keyword.toLowerCase())){
                usableData.add(x);
                break;
              }
            }
          }
        }

      }else{
        usableData.add(x);
      }
    }

    setState(() {
      filteredData = usableData;
    });

    print("Data SORT time taken: ${DateTime.now().millisecondsSinceEpoch - start}ms");
  }

  _refreshPoems([bool forced = false]) async {
    int start = DateTime.now().millisecondsSinceEpoch;
    var data;
    if (_displayChoice == FilterOptions.All) {
      data = await Provider.of<FirebaseCommunicator>(context, listen: false).loadStoredPoems(forced);
    }else{
      data = await Provider.of<FirebaseCommunicator>(context, listen: false).loadMyPoems(forced);
    }

    setState(() {
      storedData = data;
    });
    checkFilter();

    print("Data FETCH time taken: ${DateTime.now().millisecondsSinceEpoch - start} ms");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select an Existing Poem"),
        backgroundColor: Theme.of(context).primaryColorDark,
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (selectedValue){
              _refreshPoems();

              List<Map> finalGraphData = [{"id": 'All Complex Poems', "next": []}];

              int infernoCounter = 0;
              int infernoPos;

              int purgatorioCounter = 0;
              int purgatorioPos = 0;

              int paradisoCounter = 0;
              int paradisoPos = 0;

              for(var data in storedData){
                if(data[1]['translators'] != null){
                  //final uuid = '[' + Uuid().v1obj().toString().substring(0,8) + ']';
                  final uuid = ' (' + data[0] + ')';

                  var tempMap = {};
                  List graphData = [{"id": "Canto ${data[1]['cantoIndex']}" + uuid, "next": []}, {"id": data[1]['original'], "next": ["Canto ${data[1]['cantoIndex']}" + uuid]},  {"id": data[1]['title'] + uuid, "next": []}];

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

                  for (var item in sortedElementsList){
                    var translator = item['translator'];
                    for(var element in item['verse']){
                      tempMap[element] = {
                        "id": "$element" + uuid,
                        "next": [translator + uuid]
                      };
                      graphData[0]['next'].add(element + uuid);
                    }
                  }

                  for(var item in data[1]['translators']){
                    if(tempMap[item] == null){
                      tempMap[item] = {
                        "id": "$item" + uuid,
                        "next": [data[1]['title'] + uuid]
                      };
                    }
                    index++;
                  }

                  for(var item in tempMap.values){
                    graphData.add(item);
                  }

                  if(!finalGraphData[0]['next'].contains(data[1]['original'])) {
                    finalGraphData[0]['next'].add(data[1]['original']);
                  }

                  for(var value in graphData){
                    if(value['id'].substring(0, 7) == "Inferno"){
                      infernoCounter++;
                      if(infernoCounter == 1){
                        finalGraphData.add(value);
                        infernoPos = finalGraphData.length - 1;
                      }else{
                        finalGraphData[infernoPos]['next'].add(value['next'][0]);
                      }
                    }else if(value['id'].substring(0, 7) == "Purgatorio"){
                      purgatorioCounter++;
                      if(purgatorioCounter == 1){
                        finalGraphData.add(value);
                        purgatorioPos = finalGraphData.length - 1;
                      }else{
                        finalGraphData[purgatorioPos]['next'].add(value['next'][0]);
                      }
                    }else if(value['id'].substring(0, 7) == "Paradiso"){
                      paradisoCounter++;
                      if(paradisoCounter == 1){
                        finalGraphData.add(value);
                        paradisoPos = finalGraphData.length - 1;
                      }else{
                        finalGraphData[paradisoPos]['next'].add(value['next'][0]);
                      }
                    }else{
                      finalGraphData.add(value);
                    }
                  }
                }
              }

              showModalBottomSheet(context: context, enableDrag: false, builder: (ctx){
                return DirectGraph(
                  list: nodeInputFromJson(json.encode(finalGraphData)),
                  cellWidth: 160.0,
                  cellPadding: 24.0,
                  orientation: MatrixOrientation.Vertical,
                );
              });
            },
            icon: Icon(Icons.zoom_out_map),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text("All Poems"),
                value: "All",
              ),
              PopupMenuItem(
                child: Text("Simple Poems"),
                value: "Simple",
              ),
              PopupMenuItem(
                child: Text("ComplexPoems"),
                value: "Complex",
              )
            ],
          ),
          IconButton(
            onPressed: (){
              _refreshPoems(true);
            },
            icon: Icon(Icons.refresh)
          ),
          PopupMenuButton(
            onSelected: (selectedValue){
              setState(() {
                _displayChoice = selectedValue;
              });
              _refreshPoems();
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text("All Poems"),
                value: FilterOptions.All,
              ),
              PopupMenuItem(
                child: Text("My Poems"),
                value: FilterOptions.Mine,
              )
            ],
          )
        ],
      ),
      body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width-74,
                child: TextField(
                    onSubmitted: (text) {
                      setState(() {
                        keyword = text;
                      });

                      checkFilter();
                    },
                    decoration: InputDecoration(
                        labelText: "Search Poems ($searchMode)"
                    ),
                ),
              ),
              PopupMenuButton(
                onSelected: (selectedValue){
                  setState(() {
                    if(selectedValue == SearchType.PoemName){
                      searchMode = "Poem Name";
                    } else if(selectedValue == SearchType.AuthorName){
                      searchMode = "Author Name";
                    } else if(selectedValue == SearchType.PoemId) {
                      searchMode = "Poem Id";
                    } else if(selectedValue == "Verse"){
                      searchMode = "Verse";
                    } else{
                      searchMode = "Translator";
                    }
                  });
                },
                icon: Icon(Icons.more_vert),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    child: Text("Poem Name"),
                    value: SearchType.PoemName,
                  ),
                  PopupMenuItem(
                    child: Text("Author Name"),
                    value: SearchType.AuthorName,
                  ),
                  PopupMenuItem(
                    child: Text("Poem Id"),
                    value: SearchType.PoemId,
                  ),
                  PopupMenuItem(
                    child: Text("Verse"),
                    value: "Verse",
                  ),
                  PopupMenuItem(
                    child: Text("Translator"),
                    value: "Translator",
                  )
                ],
              )
            ],
          )
        ),


        storedData != null
        ? storedData.length == 0
          ? Center(child: Text("No Data Found!"))
          : Container(
            height: MediaQuery.of(context).size.height-AppBar().preferredSize.height-100,
            child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width/2,
                    child: ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (ctx, index){
                        if(index.isEven){
                          if(filteredData[index][1]['complex']){
                            return LoadedComplexPoemTile(
                                data: filteredData[index]
                            );
                          }else{
                            return LoadedPoemTile(
                              data: filteredData[index],
                              reloadPoems: (){},
                            );
                          }
                        }else{
                          return Container();
                        }
                      }
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width/2,
                    child: ListView.builder(
                        itemCount: filteredData.length,
                        itemBuilder: (ctx, index){
                          if(index.isOdd){
                            if(filteredData[index][1]['complex']){
                              return LoadedComplexPoemTile(
                                  data: filteredData[index]
                              );
                            }else{
                              return LoadedPoemTile(
                                data: filteredData[index],
                                reloadPoems: (){},
                              );
                            }
                          }else{
                            return Container();
                          }
                        }
                    ),
                  )
                ],
              ),
          )
        : Center(child: CircularProgressIndicator())
      ]
      )
    );
  }
}