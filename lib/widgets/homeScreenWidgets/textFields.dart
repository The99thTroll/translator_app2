import 'package:flutter/material.dart';
import 'containedTextField.dart';

import 'package:provider/provider.dart';
import '../../providers/canticle.dart';

class TextFields extends StatelessWidget {
  final showAll;

  TextFields({this.showAll = true});

  @override
  Widget build(BuildContext context) {
    double sWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ContainedTextField(
          width: sWidth/4.25,
          lines: 15,
          hintText: "Original text",
          index: 1,
        ),
        if(showAll == true)
        ContainedTextField(
          width: sWidth/4.25,
          lines: !Provider.of<Canticle>(context).viewMode ? 12 : 15,
          hintText: "Translated text 1",
          index: 2,
        ),
        if(showAll == true)
        ContainedTextField(
          width: sWidth/4.25,
          lines: !Provider.of<Canticle>(context).viewMode ? 12 : 15,
          hintText: "Translated text 2",
          index: 3,
        ),
        if(showAll == true)
        ContainedTextField(
          width: sWidth/4.25,
          lines: 15,
          hintText: "Output text",
          index: 4,
        ),
      ],
    );
  }
}
