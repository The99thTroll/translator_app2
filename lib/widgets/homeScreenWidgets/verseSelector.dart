import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/providers/annotations.dart';
import 'package:translator_app/providers/firebaseCommunicator.dart';

import '../../providers/textFieldManager.dart';
import '../../providers/canticle.dart';

class VerseSelector extends StatelessWidget {
  final int index;
  final double width;
  final int lines;
  final List data;

  VerseSelector({
    @required this.index,
    @required this.width,
    @required this.lines,
    @required this.data
  });

  @override
  Widget build(BuildContext context) {
    var canticle = Provider.of<Canticle>(context);
    var pressedData = canticle.verseData["BoxData"][index];

    return Container(
      width: width,
      height: lines*21.666,
      decoration: BoxDecoration(
          border: Border.all(
              width: 1,
              color: Colors.grey
          ),
          borderRadius: BorderRadius.circular(5)
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (ctx, i) {
            return Column(
              children: [
                Stack(
                  children: [
                    CheckboxListTile(
                      title: Text(
                        data[i],
                        style: TextStyle(
                            color: Colors.black
                        ),
                      ),
                      subtitle: Text("Verse ${i+1}"),
                      onChanged: (bool value){
                        canticle.setData(
                          listIndex: index,
                          itemIndex: i,
                          text: data[i]
                        );
                      },
                      value: pressedData[i],
                    ),


                    Positioned(
                      bottom: 0,
                      right: 20,
                      child: Stack(
                        children: [
                          InkWell(
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onTap: (){
                              Provider.of<Annotations>(context).getAndUseData(
                                  context: context,
                                  index: i,
                                  username: Provider.of<FirebaseCommunicator>(context).userName
                              );
                            },
                            child: Icon(
                              Icons.add_circle,
                              color: Colors.green[600],
                            ),
                          ),

                          if(Provider.of<Annotations>(context).annotations[i].length > 1)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: Colors.yellow[700],
                                  borderRadius: BorderRadius.circular(90.0)
                              ),
                            )
                        ],
                      ),
                    )
                  ],
                ),
                Divider()
              ],
            );
          },
        ),
      ),
    );
  }
}
