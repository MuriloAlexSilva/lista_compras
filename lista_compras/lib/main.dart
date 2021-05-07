import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'app/view/home_page.dart';

main(List<String> args) {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
    theme: ThemeData.dark(),
  ));
}
