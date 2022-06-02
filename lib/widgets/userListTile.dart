import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserListTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final List signIns;

  UserListTile({
    this.title,
    this.subtitle,
    this.signIns
  });

  @override
  _UserListTileState createState() => _UserListTileState();
}

class _UserListTileState extends State<UserListTile> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black
                ),
              ),
              Text(
                widget.subtitle,

                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600]
                ),
              )
            ],
          ),
          SizedBox(height: 5),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                    onPressed: (){
                      setState(() {
                        open = !open;
                      });
                    },
                    icon: Icon(
                        !open
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up
                    ),
                    label: Text(
                        !open
                            ? "Show User Logins"
                            : "Close User Logins"
                    )
                ),
                if(open)
                Container(
                  height: min(210, widget.signIns.length*23.0),
                  child: ListView.builder(
                    itemCount: widget.signIns.length,
                    itemBuilder: (context, index){
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text("${index+1}) ${DateFormat('MMM dd, yyyy -').add_jm().format(DateTime.parse(widget.signIns[index]))}"),
                      );
                    }
                  ),
                ),
              ],
          )
        ],
      ),
    );
  }
}
