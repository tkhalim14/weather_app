import 'package:flutter/material.dart';
import 'package:weatherapp/pages/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Weather App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryIconTheme: const IconThemeData(
          color: Colors.red,
        ),
      ),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: LocationScreen(),
    );
  }
}
