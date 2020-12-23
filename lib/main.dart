import 'package:flutter/material.dart';
import 'package:heartry/screens/poems_screen/poems_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Heartry",
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(
              const EdgeInsets.all(10.0),
            ),
            backgroundColor: MaterialStateProperty.all(
              Colors.deepPurple.shade50,
            ),
            overlayColor: MaterialStateProperty.all(
              Colors.deepPurple.shade100,
            ),
          ),
        ),
        accentTextTheme: TextTheme(
          headline3: const TextStyle(
            color: Colors.deepPurpleAccent,
          ),
          headline4: const TextStyle(
            color: Colors.deepPurpleAccent,
            fontWeight: FontWeight.w400,
          ),
          headline5: const TextStyle(
            color: Colors.deepPurpleAccent,
            fontWeight: FontWeight.w400,
          ),
          subtitle1: TextStyle(
            color: Colors.deepPurpleAccent.shade100,
          ),
        ),
      ),
      home: const PoemScreen(),
    );
  }
}
