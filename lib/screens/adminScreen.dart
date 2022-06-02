import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/providers/firebaseCommunicator.dart';
import 'package:translator_app/widgets/containedElevatedButton.dart';
import 'package:intl/intl.dart';
import '../widgets/userListTile.dart';

class AdminScreen extends StatefulWidget {
  static const routeName = '/admin';

  @override
  _AdminScreen createState() => _AdminScreen();
}

class _AdminScreen extends State<AdminScreen> {
  String currentTask = "";
  List users = [];

  @override
  void initState() {
    _refreshUsers();
    super.initState();
  }

  void _refreshUsers() async {
    var data = await Provider.of<FirebaseCommunicator>(context, listen: false).getUsers();

    setState(() {
      users = data;
    });

    print(users);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Panel"),
        backgroundColor: Theme.of(context).primaryColorDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ContainedElevatedButton(
                  function: (){
                    setState(() {
                      currentTask = "search";
                    });
                  },
                  label: "Search Users"
                ),
                ContainedElevatedButton(
                    function: (){
                      setState(() {
                        currentTask = "delete";
                      });
                    },
                    label: "Delete Poems"
                ),
                ContainedElevatedButton(
                    function: (){
                      _refreshUsers();
                    },
                    label: "[Placeholder]"
                )
              ],
            ),
            SizedBox(height: 8),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 5,
              color: Theme.of(context).primaryColor,
            ),

            if(currentTask == "")
              Center(child: Text("Select An Option!"))
            else if(currentTask == "search")
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width-32,
                    child: TextField(
                        onSubmitted: (text) {
                          setState(() {

                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Search Users",
                          icon: Icon(Icons.search),
                        )
                    ),
                  ),

                  Container(
                    height: MediaQuery.of(context).size.height-164,
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, i){
                        return UserListTile(
                          title: users[i][1]['name'],
                          subtitle: 'Joined ${DateFormat('MMM dd, yyyy').format(DateTime.parse(users[i][1]['signUpDate']))}',
                          signIns: users[i][1]['signIns'],
                        );
                      }
                    ),
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}



