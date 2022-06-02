import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/providers/annotations.dart';

import '../../providers/canticle.dart';

class ComposeButton extends StatelessWidget {
  final width;
  static const List options = ["Create New Poem", "Enter Complex Editing", "Load Existing Poem"];

  ComposeButton(this.width);

  @override
  Widget build(BuildContext context) {
    var canticle = Provider.of<Canticle>(context);

    return PopupMenuButton(
      child: Container(
          width: width,
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(
                color: Colors.black38,
                blurRadius: 1.0,
                spreadRadius: 0.0,
                offset: Offset(0.0, 1.5)
            )],
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Text(
            "Compose",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w500
            ),
          )
      ),
      onSelected: (dynamic selected){
        if(selected == "Create New Poem"){
          canticle.clearAll(false, false, false);
          Provider.of<Annotations>(context).clear();
          if(canticle.viewMode == true) {
            canticle.toggleViewMode();
          }
        }else if(selected == "Enter Complex Editing"){
          Navigator.of(context).pushNamed("/complex");
        }else{
          Navigator.of(context).pushNamed("/select");
        }
      },
      itemBuilder: (context) {
        return options.map(
           (text) => PopupMenuItem(
              child: Text(text),
             value: text,
            )
        ).toList();
      },
    );
  }
}
