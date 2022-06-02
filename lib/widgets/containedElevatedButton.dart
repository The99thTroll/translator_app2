import 'package:flutter/material.dart';

class ContainedElevatedButton extends StatelessWidget {
  final double width;
  final Function function;
  final String label;

  ContainedElevatedButton({
    @required this.width,
    @required this.function,
    @required this.label
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: ElevatedButton(
          onPressed: function,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          )
      ),
    );
  }
}