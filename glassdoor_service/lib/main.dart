import 'package:glassdoor_service/view/home_page.dart';
import 'package:flutter/material.dart';

class GlassdoorApp extends StatelessWidget {
  const GlassdoorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() => runApp(const GlassdoorApp());
