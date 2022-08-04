import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/widgets/loadedComplexPoem.dart';

import '../widgets/loadedPoemTile.dart';

import '../providers/canticle.dart';
import '../providers/firebaseCommunicator.dart';

import 'package:graphite/core/matrix.dart';
import 'package:graphite/core/typings.dart';
import 'package:graphite/graphite.dart';

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
  }

  _refreshPoems([bool forced = false]) async {
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
              for(var item in storedData){
                if(item != null){

                }
              }
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