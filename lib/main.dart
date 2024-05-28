import 'package:coin_collector/AddCoinScreen.dart';
import 'package:coin_collector/CoinListScreen.dart';
import 'package:coin_collector/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //title: 'CoinCollector',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        hintColor: Colors.orangeAccent.withOpacity(0.3),
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold, color: Colors.amber),
          headline6: TextStyle(fontSize: 18.0, color: Colors.grey),
          bodyText2: TextStyle(fontSize: 14.0, color: Colors.brown),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.amber.withOpacity(0.9),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.amber,
        ),
      ),
      home: CoinListScreen(),
    );
  }
}


