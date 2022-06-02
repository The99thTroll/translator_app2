import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/canticle.dart';
import '../../providers/textFieldManager.dart';

import '../containedElevatedButton.dart';

class PageSelectButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double sWidth = MediaQuery.of(context).size.width;
    double sHeight = MediaQuery.of(context).size.height;

    var canticle = Provider.of<Canticle>(context);
    var manager = Provider.of<TextFieldManager>(context);

    void setTextFields(){
      manager.setField(0, canticle.getVerse(0, canticle.currentCanto));
      manager.setField(1, canticle.getVerse(canticle.translator1Index+1, canticle.currentCanto));
      manager.setField(2, canticle.getVerse(canticle.translator2Index+1, canticle.currentCanto));
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              ContainedElevatedButton(
                  width: sWidth/6,
                  function: (){
                    canticle.setCanto("1");
                    setTextFields();
                  },
                  label: "First"
              ),
              SizedBox(width: 10),
              ContainedElevatedButton(
                  width: sWidth/6,
                  function: (){
                    if (int.parse(canticle.currentCanto) < 4) {
                      canticle.setCanto((int.parse(canticle.currentCanto) + 1).toString());
                    }
                    setTextFields();
                  },
                  label: "Next"
              ),
            ],
          ),
          Row(
            children: [
              ContainedElevatedButton(
                  width: sWidth/6,
                  function: (){
                    if (int.parse(canticle.currentCanto) > 1) {
                      canticle.setCanto((int.parse(canticle.currentCanto) - 1).toString());
                    }
                    setTextFields();
                  },
                  label: "Previous"
              ),
              SizedBox(width: 10),
              ContainedElevatedButton(
                  width: sWidth/6,
                  function: (){
                    canticle.setCanto("4");
                    setTextFields();
                  },
                  label: "Last"
              ),
            ],
          )
        ]
    );
  }
}
