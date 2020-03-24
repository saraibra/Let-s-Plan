
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:letsplan/models/task.dart';
import 'package:letsplan/ui/add_list_page.dart';
import 'package:letsplan/ui/details_page.dart';

class TaskPage extends StatefulWidget {
 final FirebaseUser user;

  const TaskPage({Key key, @required this.user}) : super(key: key);
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          _getToolbar(context),
          new Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    Expanded(
                        flex: 2,
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Task',
                              style: new TextStyle(
                                  fontSize: 30.0, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Lists',
                              style: new TextStyle(
                                  fontSize: 28.0, color: Colors.grey),
                            )
                          ],
                        )),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: new Column(
                  children: <Widget>[
                    new Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: new BoxDecoration(
                          border: new Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.all(Radius.circular(7.0))),
                      child: new IconButton(
                        icon: new Icon(Icons.add),
                        onPressed: _addTaskPressed,
                        iconSize: 30.0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text('Add List',
                          style: TextStyle(color: Colors.black45)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 50.0),
            child: Container(
              height: 360.0,
              padding: EdgeInsets.only(bottom: 25.0),
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowGlow();
                },
                child: new StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection(widget.user.uid)
                        .orderBy("date", descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData)
                        return new Center(
                            child: CircularProgressIndicator(
                          backgroundColor: Colors.blue,
                        ));
                      return new ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(left: 40.0, right: 40.0),
                        scrollDirection: Axis.horizontal,
                        children: getExpenseItems(snapshot),
                      );
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _addTaskPressed() async {
    Navigator.of(context).push(new PageRouteBuilder(
        pageBuilder: (_, __, ___) => NewTaskPage(
              user: widget.user,
            ),
        transitionsBuilder: (context, animation, secondryAnimation, child) =>
            new ScaleTransition(
              scale: new Tween<double>(
                begin: 1.5,
                end: 1,
              ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Interval(
                    0.50,
                    1.00,
                    curve: Curves.linear,
                  ))),
              child: ScaleTransition(
                scale: new Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Interval(0.00, 0.50, curve: Curves.linear),
                  ),
                ),
                child: child,
              ),
            )));
  }

  Padding _getToolbar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Image(
              width: 40.0,
              height: 40.0,
              fit: BoxFit.cover,
              image: new AssetImage('assets/list.png')),
        ],
      ),
    );
  }

  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<Task> tasklists = new List(), tasksList2;
    Map<String, List<Task>> userMap = new Map();
    List<String> cardColor = new List();
    if (widget.user.uid.isNotEmpty) {
      cardColor.clear();
      snapshot.data.documents.map<List>((f) {
        String color;
        f.data.forEach((a, b) {
          if (b.runtimeType == bool) {
            tasklists.add(new Task(name: a, isDone: b));
          }
          if (b.runtimeType == String && a == "color") {
            color = b;
          }
        });
        tasksList2 = new List<Task>.from(tasklists);
        for (int i = 0; i < tasksList2.length; i++) {
          if (tasksList2.elementAt(i).isDone == false) {
            userMap[f.documentID] = tasksList2;
            cardColor.add(color);
            break;
          }
        }
        if (tasksList2.length == 0) {
          userMap[f.documentID] = tasksList2;
          cardColor.add(color);
        }
        tasklists.clear();
      }).toList();
      return new List.generate(userMap.length, (int index) {
        return new GestureDetector(
          onTap: () {
            Navigator.of(context).push(new PageRouteBuilder(
              pageBuilder: (_, __, ___) => new DetailsPage(
                user: widget.user,
                i: index,
                currentList: userMap,
                color: cardColor.elementAt(index),
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      new ScaleTransition(
                scale: new Tween<double>(begin: 1.5, end: 1).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Interval(
                      0.50,
                      1.00,
                      curve: Curves.linear,
                    ),
                  ),
                ),
                child: ScaleTransition(
                  scale: new Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Interval(
                        0.00,
                        0.50,
                        curve: Curves.linear,
                      ),
                    ),
                  ),
                  child: child,
                ),
              ),
            ));
          },
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            color: Color(int.parse(cardColor.elementAt(index))),
            child: new Container(
              width: 220.0,
              child: Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 15.0),
                      child: Container(
                        child: Text(
                          userMap.keys.elementAt(index),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(
                              margin: EdgeInsets.only(left: 50.0),
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 30.0, left: 15.0, right: 5.0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 220,
                            child: ListView.builder(
                              itemCount: userMap.values.elementAt(index).length,
                              itemBuilder: (BuildContext context, int i) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(
                                      userMap.values
                                              .elementAt(index)
                                              .elementAt(i)
                                              .isDone
                                          ? FontAwesomeIcons.checkCircle
                                          : FontAwesomeIcons.circle,
                                      color: userMap.values
                                              .elementAt(index)
                                              .elementAt(i)
                                              .isDone
                                          ? Colors.white70
                                          : Colors.white,
                                      size: 14,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10.0),
                                    ),
                                    Flexible(
                                      child: Text(
                                        userMap.values
                                            .elementAt(index)
                                            .elementAt(i)
                                            .name,
                                        style: userMap.values
                                                .elementAt(index)
                                                .elementAt(i)
                                                .isDone
                                            ? TextStyle(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                color: Colors.white70,
                                                fontSize: 16)
                                            : TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                              ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      });
    }
  }
}
