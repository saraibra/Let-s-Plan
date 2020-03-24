import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share/share.dart';

class SettingsPage extends StatefulWidget {
  FirebaseUser user;
  SettingsPage({Key key, @required this.user}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              _getToolbar(context),
              Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 1.5,
                        color: Colors.grey,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Task',
                            style: TextStyle(
                                fontSize: 30.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Settings',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 28.0,
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 1.5,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 50,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(
                          FontAwesomeIcons.cogs,
                          color: Colors.grey,
                        ),
                        title: Text("Version"),
                        trailing: Text("1.0.0"),
                      ),
                      ListTile(
                        leading: Icon(
                          FontAwesomeIcons.star,
                          color: Colors.blue,
                        ),
                        onTap: _rateApp,
                        title: Text("Rate Let's Plan"),
                        trailing: Icon(Icons.arrow_right),
                      ),
                      ListTile(
                        leading: Icon(FontAwesomeIcons.shareAlt,
                        color: Colors.blue,
                        ),
                        title: Text("Share Let's Plan"),
                        trailing: Icon(
                          Icons.arrow_right
                        ),
                        onTap: _shareApp,
                      )
                    ],
                  ),
                ),
              ],
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
 Padding _getToolbar(BuildContext context) {
        return new Padding(
      padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
      child:
      new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        new Image(
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover,
            image: new AssetImage('assets/list.png')
        ),
      ]),
    );
  }

  void _rateApp() async {
    LaunchReview.launch();
  }

  void _shareApp()async {
    Share.share('');
  }
}
