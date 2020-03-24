import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:letsplan/ui/done_page.dart';
import 'package:letsplan/ui/settings_page.dart';
import 'package:letsplan/ui/task_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _currentUser = await _signInAnonymously();

  runApp(LetsPlan());
}

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseUser _currentUser;
Future<FirebaseUser> _signInAnonymously() async {
  await _auth.signInAnonymously();
  return _auth.currentUser();
}

class LetsPlan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ('Lets Plan'),
      debugShowCheckedModeBanner: false,
      home: HomePage(
        user: _currentUser,
      ),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

class HomePage extends StatefulWidget {
  final FirebaseUser user;

  const HomePage({Key key, this.user}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final List<Widget> _children = [
    TaskPage(
      user: _currentUser,
    ),
    DonePage(
      user: _currentUser,
    ),
    SettingsPage(
      user: _currentUser,
    ),
  ];
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTabed,
          currentIndex: _currentIndex,
          fixedColor: Colors.deepPurple,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: new Icon(FontAwesomeIcons.calendarCheck),
              title: Text(''),
            ),
            BottomNavigationBarItem(
                icon: new Icon(FontAwesomeIcons.calendarDay), title: Text('')),
            BottomNavigationBarItem(
                icon: new Icon(FontAwesomeIcons.slidersH), title: Text(''))
          ]),
      body: _children[_currentIndex],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  void onTabTabed(int index) {
    _currentIndex = index;
  }
}
