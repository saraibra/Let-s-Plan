import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:letsplan/models/task.dart';
import 'package:letsplan/ui/details_page.dart';

class DonePage extends StatefulWidget {
  final FirebaseUser user;

  const DonePage({Key key,@required this.user}) : super(key: key);
  @override
  _DonePageState createState() => _DonePageState();
}

class _DonePageState extends State<DonePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          _getToolbar(context),
          Column(
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
                        )),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Task",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Done",
                            style: TextStyle(color: Colors.grey, fontSize: 28),
                          )
                        ],
                      ),
                    ),
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
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 175.0),
            child: Container(
              padding: EdgeInsets.only(bottom: 25.0),
              height: 360,
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overScroll) {
                  overScroll.disallowGlow();
                },
                child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection(widget.user.uid)
                        .orderBy("date", descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.blue,
                          ),
                        );
                      }
                      return ListView(
                        physics: BouncingScrollPhysics(),
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

  _getToolbar(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
      child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        new Image(
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover,
            image: new AssetImage('assets/list.png')),
      ]),
    );
  }

  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<Task> tasksList = new List(), tasksList2;
    Map<String, List<Task>> userMap = new Map();
    List<String> cardColors = new List();
    if (widget.user.uid.isNotEmpty) {
      cardColors.clear();
      snapshot.data.documents.map<List>((f) {
        f.data.forEach((a, b) {
          if (b.runtimeType == bool) {
            tasksList.add(new Task(
              name: a,
              isDone: b,
            ));
          }
          if (b.runtimeType == String && a == "color") {
            cardColors.add(b);
          }
        });
        tasksList2 = new List<Task>.from(tasksList);
        userMap[f.documentID] = tasksList2;
        for (int i = 0; i < tasksList2.length; i++) {
          if (tasksList2.elementAt(i).isDone == false) {
            userMap.remove(f.documentID);
            if (cardColors.isNotEmpty) {
              cardColors.removeLast();
            }
            break;
          }
        }
        if (tasksList2.length == 0) {
          userMap.remove(f.documentID);
          cardColors.removeLast();
        }
        tasksList.clear();
      }).toList();
      return new List.generate(userMap.length, (int index) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              new PageRouteBuilder(
                pageBuilder: (_, __, ___) => new DetailsPage(
                  user: widget.user,
                  i: index,
                  currentList: userMap,
                  color: cardColors.elementAt(index),
                ),
                transitionsBuilder:
                    (context, animatiom, secondryAnimation, child) =>
                        new ScaleTransition(
                  scale: new Tween<double>(
                    begin: 1.5,
                    end: 1.0,
                  ).animate(
                    CurvedAnimation(
                      parent: animatiom,
                      curve: Interval(
                        0.50,
                        1.00,
                        curve: Curves.linear,
                      ),
                    ),
                  ),
                  child: ScaleTransition(
                    scale: new Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(
                      CurvedAnimation(
                        parent: animatiom,
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
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            color: Color(int.parse(cardColors.elementAt(index))),
            child: new Container(
              width: 220.0,
              //height: 100.0,
              child: Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 20.0, bottom: 15.0),
                      child: Container(
                        child: Text(
                          userMap.keys.elementAt(index),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.0,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5.0),
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
                            height: 220.0,
                            child: ListView.builder(
                                //physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    userMap.values.elementAt(index).length,
                                itemBuilder: (BuildContext ctxt, int i) {
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
                                        size: 14.0,
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
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  color: Colors.white70,
                                                  fontSize: 17.0,
                                                )
                                              : TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17.0,
                                                ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
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
