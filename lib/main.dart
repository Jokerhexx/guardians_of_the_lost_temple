import 'package:flutter/material.dart';
import 'package:guardians_of_the_lost_temple/lib/main_screen.dart';

void main() {
  runApp(GuardiansOfTheLostTemple());
}

class GuardiansOfTheLostTemple extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardians of the Lost Temple',
      theme: ThemeData.dark(),
      home: MainScreen(),
    );
  }
}
