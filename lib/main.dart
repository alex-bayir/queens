import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

void main() async {
  runApp(const App());
}

class App extends StatefulWidget{
  static late SharedPreferences shared;
  static final ValueNotifier<ThemeMode> notifier = ValueNotifier(ThemeMode.system);

  const App({super.key});
  @override
  State<StatefulWidget> createState() => AppState();
  
}

class AppState extends State<App>{

  @override
  void initState(){
    SharedPreferences.getInstance().then((value) => App.shared=value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: App.notifier,
      builder: (_, ThemeMode mode, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Queens',
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: mode,
        home: const Home(title: 'Queens'),
      )
    );
  }

  ThemeMode loadThemeMode()=>switch(App.shared.getString('Theme Mode')){
    'dark'=>ThemeMode.dark,
    'light'=>ThemeMode.light,
    _ => ThemeMode.system
  };
}
