import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/canticle.dart';
import '../widgets/homeScreenWidgets/home.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool viewMode = true;

  @override
  Widget build(BuildContext context) {
    var canticle = Provider.of<Canticle>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon:
              Icon(
                Icons.supervised_user_circle
              ),
            onPressed: (){
              Navigator.of(context).pushNamed("/admin");
            }
          )
        ],
        title: Text("Text Translator: ${
            canticle.loadedName.isNotEmpty
            ? canticle.loadedName
            : "${canticle.currentCanticle} - ${canticle.currentCanto}"
        }"),
        backgroundColor: Theme.of(context).primaryColorDark,
      ),
      body: Home(),
    );
  }
}



