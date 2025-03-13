// ignore_for_file: must_be_immutable, use_key_in_widget_constructors

import 'package:easygps/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // إخفاء شعار debug
      initialRoute: '/', // تعيين الصفحة الرئيسية عند بدء التطبيق
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => Home());
          default:
            return MaterialPageRoute(builder: (context) => Home());
        }
      },
    );
  }
}
