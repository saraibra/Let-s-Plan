import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:letsplan/models/task.dart';
import 'package:letsplan/utils/dimond_fab.dart';

class DetailsPage extends StatefulWidget {
  final FirebaseUser user;
  final int i;
  final Map<String, List<Task>> currentList;
  final String color;

  const DetailsPage(
      {Key key,
      @required this.user,
      @required this.i,
      @required this.currentList,
      @required this.color})
      : super(key: key);
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  TextEditingController itemController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          _getToolbar(context),
          Container(
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowGlow();
              },
              child: new StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection(widget.user.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          backgroundColor: currentColor,
                        ),
                      );
                      return Container(
                        child: getExpenseItems(snapshot),
                      );
                    }
                  }),
            ),
          ),
        ],
      ),
      floatingActionButton: DiamondFab(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: currentColor)),
                            labelText: 'Item',
                            hintText: 'Item',
                            contentPadding: EdgeInsets.only(
                                left: 16.0,
                                top: 20.0,
                                right: 16.0,
                                bottom: 5.0)),
                        controller: itemController,
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  ButtonTheme(
                    child: RaisedButton(
                      elevation: 3.0,
                      onPressed: () {
                        if (itemController.text.isNotEmpty &&
                            !widget.currentList.values
                                .contains(itemController.text.toString())) {
                          Firestore.instance
                              .collection(widget.user.uid)
                              .document(
                                  widget.currentList.keys.elementAt(widget.i))
                              .updateData(
                                  {itemController.text.toString(): false});
                          itemController.clear();
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text('Add'),
                      color: currentColor,
                      textColor: const Color(0xffffffff),
                    ),
                  )
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: currentColor,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<Task> tasksList = new List();
    int nbIsDone = 0;
    if (widget.user.uid.isNotEmpty) {
      snapshot.data.documents.map<Column>((f) {
        if (f.documentID == widget.currentList.keys.elementAt(widget.i)) {
          f.data.forEach((a, b) {
            if (b.runtimeType == bool) {
              tasksList.add(new Task(name: a, isDone: b));
            }
          });
        }
      }).toList();
      tasksList.forEach((i) {
        if (i.isDone) {
          nbIsDone++;
        }
      });
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 150.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 5.0, left: 50.0, right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          widget.currentList.keys.elementAt(widget.i),
                          softWrap: true,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 35.0),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return new AlertDialog(
                                title: Text('Delete: ' +
                                    widget.currentList.keys
                                        .elementAt(widget.i)
                                        .toString()),
                                content: Text(
                                  'Are you want to delete this list?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                actions: <Widget>[
                                  ButtonTheme(
                                    child: RaisedButton(
                                        child: Text('No'),
                                        color: currentColor,
                                        textColor: const Color(0xffffffff),
                                        elevation: 3.0,
                                        onPressed: () {
                                          Navigator.pop(context);
                                        }),
                                  ),
                                  ButtonTheme(
                                    child: RaisedButton(
                                      child: Text('Yes'),
                                      color: currentColor,
                                      textColor: const Color(0xffffffff),
                                      elevation: 3.0,
                                      onPressed: () {
                                        Firestore.instance
                                            .collection(widget.user.uid)
                                            .document(widget.currentList.keys
                                                .elementAt(widget.i));
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Icon(
                          FontAwesomeIcons.trash,
                          color: currentColor,
                          size: 25.0,
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.0, left: 50.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        nbIsDone.toString() +
                            " of " +
                            tasksList.length.toString() +
                            " tasks ",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: Container(
                            margin: EdgeInsets.only(left: 50.0),
                            color: Colors.grey,
                            height: 1.5,
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Color(0xFFFCFCFC),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height - 350,
                          child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: tasksList.length,
                              itemBuilder: (BuildContext context, int i) {
                                return new Slidable(
                                  actionExtentRatio: 0.25,
                                  child: GestureDetector(
                                    onTap: () {
                                      Firestore.instance
                                          .collection(widget.user.uid)
                                          .document(widget.currentList.keys
                                              .elementAt(widget.i))
                                          .updateData({
                                        tasksList.elementAt(i).name:
                                            !tasksList.elementAt(i).isDone,
                                      });
                                    },
                                    child: Container(
                                      height: 50.0,
                                      color: tasksList.elementAt(i).isDone
                                          ? Color(0xFFF0F0F0)
                                          : Color(0xFFFCFCFC),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              tasksList.elementAt(i).isDone
                                                  ? FontAwesomeIcons.checkSquare
                                                  : FontAwesomeIcons.square,
                                              color:
                                                  tasksList.elementAt(i).isDone
                                                      ? currentColor
                                                      : Colors.black,
                                              size: 20.0,
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 30),
                                              child: Flexible(
                                                child: Text(
                                                  tasksList.elementAt(i).name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: tasksList
                                                          .elementAt(i)
                                                          .isDone
                                                      ? TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                          color: currentColor,
                                                          fontSize: 27.0)
                                                      : TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 27,
                                                        ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  delegate: SlidableBehindDelegate(),
                                  secondaryActions: <Widget>[
                                    new IconSlideAction(
                                      caption: 'Delete',
                                      color: Colors.red,
                                      icon: Icons.delete,
                                      onTap: () {
                                        Firestore.instance
                                            .collection(widget.user.uid)
                                            .document(widget.currentList.keys
                                                .elementAt(widget.i))
                                            .updateData({
                                          tasksList.elementAt(i).name: ""
                                        });
                                      },
                                    )
                                  ],
                                );
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();
    pickerColor = Color(int.parse(widget.color));
    currentColor = Color(int.parse(widget.color));
  }

  Color pickerColor;
  Color currentColor;

  ValueChanged<Color> onColorChanged;
  changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  Padding _getToolbar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Image(
              height: 35.0,
              width: 35.0,
              fit: BoxFit.cover,
              image: new AssetImage('assets/list.png')),
          RaisedButton(
            elevation: 3.0,
            onPressed: () {
              pickerColor = currentColor;
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Pick a color!'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: pickerColor,
                        onColorChanged: changeColor,
                        enableLabel: true,
                        colorPickerWidth: 1000.0,
                        pickerAreaHeightPercent: 0.7,
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Got it'),
                        onPressed: () {
                          Firestore.instance
                              .collection(widget.user.uid)
                              .document(
                                  widget.currentList.keys.elementAt(widget.i))
                              .updateData(
                                  {"color": pickerColor.value.toString()});
                          setState(() => currentColor = pickerColor);
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                },
              );
            },
            child: Text('Color'),
            color: currentColor,
            textColor: const Color(0xffffffff),
          ),
          GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Icon(Icons.close,
            size: 40,
            color: currentColor,
            ),
          )
        ],
      ),
    );
  }
}
