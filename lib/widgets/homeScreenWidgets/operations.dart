import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/canticle.dart';

class Operations extends StatefulWidget {
  @override
  _OperationsState createState() => _OperationsState();
}

class _OperationsState extends State<Operations> {
  @override
  Widget build(BuildContext context) {
    var viewMode = Provider.of<Canticle>(context).viewMode;

    return Container(
      width: 150,
      child: Column(
        children: <Widget>[
          Text(
            "Operation Mode",
            style: Theme.of(context).textTheme.subtitle2,
          ),
          CheckboxListTile(
              title: Text("View"),
              value: viewMode,
              onChanged: (bool value){
                if(viewMode == false){
                  Provider.of<Canticle>(context).toggleViewMode();
                }
              }
          ),
          CheckboxListTile(
              title: Text("Compose"),
              value: !viewMode,
              onChanged: (bool value){
                if(viewMode == true){
                  if (Provider.of<Canticle>(context).complexLoaded == false) {
                    Provider.of<Canticle>(context).toggleViewMode();
                  }else{
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('OOPS!'),
                        content: Text("You have a complex poem loaded! Please either load a simple poem or start a new poem to proceed. To edit the complex poem, use the complex poem editer."),
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
              }
          ),
        ],
      ),
    );
  }
}
