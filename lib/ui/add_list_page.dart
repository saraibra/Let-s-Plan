import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class NewTaskPage extends StatefulWidget {
  final FirebaseUser user;

  const NewTaskPage({Key key, @required this.user}) : super(key: key);
  @override
  _NewTaskPageState createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  final GlobalKey<ScaffoldState> _scafoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _taskNameController = new TextEditingController();
  Color currentColor = Color(0xff6633ff);
  Color pickerColor = Color(0xff6633ff);
  ValueChanged<Color> onColorChanged;
  bool saving = false;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = new Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  Future<Null> initConnectivity() async {
    String connectionStatus;
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    } on PlatformException catch (e) {
      connectionStatus = 'Failed to connect the internet';
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _connectionStatus = connectionStatus;
    });
  }

  Future<void> addToFirebase() async {
    setState(() {
      saving = true;
    });
    if (_connectionStatus == "ConnectivityResult.none") {
      showInSnackBar("No internet connection currently available");
      setState(() {
        saving = false;
      });
    } else {
      bool isExist = false;
      QuerySnapshot querySnapshot =
          await Firestore.instance.collection(widget.user.uid).getDocuments();
      querySnapshot.documents.forEach((doc) {
        if (_taskNameController.text.toString() == doc.documentID) {
          isExist = true;
        }
      });
      if (!isExist && _taskNameController.text.isNotEmpty) {
        await Firestore.instance
            .collection(widget.user.uid)
            .document(_taskNameController.text.toString().trim())
            .setData({
          "color": currentColor.value.toString(),
          "date": DateTime.now().millisecondsSinceEpoch,
        });
        _taskNameController.clear();
        pickerColor = Color(0xff6633ff);
        currentColor = Color(0xff6633ff);
        Navigator.of(context).pop();
      }
      if (isExist) {
        showInSnackBar("This task already exists");
        setState(() {
          saving = false;
        });
      }
      if (_taskNameController.text.isEmpty) {
        showInSnackBar("Please enter a name");
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafoldKey,
      body: ModalProgressHUD(
        inAsyncCall: saving,
        child: new Stack(
          children: <Widget>[
            _getToolbar(context),
            Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 100.0),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'New',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'List',
                                  style: TextStyle(
                                    fontSize: 28,
                                    color: Colors.grey,
                                  ),
                                )
                              ],
                            )),
                        Expanded(
                          child: Container(
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            border: new OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Colors.teal,
                            )),
                            labelText: 'Task name',
                            contentPadding: EdgeInsets.only(
                                left: 16.0,
                                top: 20.0,
                                right: 16.0,
                                bottom: 5.0),
                          ),
                          controller: _taskNameController,
                          autocorrect: true,
                          autofocus: true,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 22,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.text,
                          maxLength: 20,
                        ),
                        new Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                        ),
                        ButtonTheme(
                          minWidth: double.infinity,
                          child: RaisedButton(
                            elevation: 3,
                            onPressed: () {
                              pickerColor = currentColor;
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Pick color!'),
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
                                            onPressed: () {
                                              setState(() =>
                                                  currentColor = pickerColor);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Got it'))
                                      ],
                                    );
                                  });
                            },
                            child: Text('Card color'),
                            color: currentColor,
                            textColor: const Color(0xffffffff),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 50,
                    ),
                    child: Column(
                      children: <Widget>[
                        RaisedButton(
                          child: Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          elevation: 4,
                          color: Colors.blue,
                          splashColor: Colors.deepPurple,
                          onPressed: addToFirebase,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getToolbar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40, left: 10),
      child: BackButton(color: Colors.black,),
    );
  }

  void showInSnackBar(String value) {
    _scafoldKey.currentState?.removeCurrentSnackBar();
    _scafoldKey.currentState?.showSnackBar(new SnackBar(
      content: Text(
        value,
        textAlign: TextAlign.center,
      ),
      backgroundColor: currentColor,
      duration: Duration(seconds: 3),
    ));
  }

  void changeColor(Color color) {
    setState(() {
      pickerColor = color;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scafoldKey.currentState?.dispose();
    _connectivitySubscription?.cancel();
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectionStatus = result.toString();
      });
    });
  }
}
