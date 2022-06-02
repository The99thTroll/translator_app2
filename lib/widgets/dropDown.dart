import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/canticle.dart';

class DropDown extends StatefulWidget {

  final List<String> options;
  String selectedOption;
  final double cWidth;
  final Function update;

  DropDown({
    @required this.options,
    @required this.selectedOption,
    @required this.update,
    this.cWidth,
  });

  @override
  _DropDownState createState() => _DropDownState(this.selectedOption);
}

class _DropDownState extends State<DropDown> {
  String selected;
  _DropDownState(this.selected);

  @override
  void initState() {
    setState(() {
      selected = selected;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.cWidth,
      child: DropdownButton<String>(
        value: selected,
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: Theme.of(context).primaryColor),
        underline: Container(
          height: 2,
          color: Theme.of(context).primaryColorLight,
        ),
        onChanged: (String newValue) {
          this.setState(() {
            selected = newValue;
          });
          widget.update(newValue);
        },
        items: widget.options.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: SizedBox(
              width: widget.cWidth == null ? null : widget.cWidth/1.2,
              child: Text(value)
            ),
          );
        }).toList(),
      ),
    );
  }
}
