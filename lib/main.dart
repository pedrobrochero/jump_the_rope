import 'package:flutter/material.dart';
import 'package:jump_the_rope/providers/prefs_provider.dart';
import 'package:jump_the_rope/ui/add_edit_user.dart';
import 'package:jump_the_rope/ui/add_info.dart';
import 'package:jump_the_rope/ui/home.dart';
import 'package:jump_the_rope/ui/login.dart';
 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = PrefsProvider();
  await prefs.initPrefs();
  
  runApp(MyApp());
}
 
class MyApp extends StatelessWidget {
  final prefs = PrefsProvider();

  @override
  Widget build(BuildContext context) {
    print(prefs.userId);
    return MaterialApp(
      title: 'Jump the rope',
      initialRoute: prefs.userId != null ? HomeUI.ROUTE : LoginUI.ROUTE,
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => HomeUI(),

        LoginUI.ROUTE: (BuildContext context) => LoginUI(),
        HomeUI.ROUTE: (BuildContext context) => HomeUI(),
        AddInfoUI.ROUTE: (BuildContext context) => AddInfoUI(),
        AddEditUser.ROUTE: (BuildContext context) => AddEditUser(),
      },
      theme: ThemeData(
        primaryColor: Color(0xff7b4397),
        accentColor: Color(0xffdc2430),
        textTheme: TextTheme(
          subtitle1: TextStyle(fontSize: 14),
          bodyText2: TextStyle(fontSize: 14),
        )
      ),
    );
  }
}