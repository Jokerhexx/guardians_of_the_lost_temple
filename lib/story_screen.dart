import 'package:flutter/material.dart';

class StoryScreen extends StatelessWidget {
  final String storyText;
  final VoidCallback onContinue;

  StoryScreen({required this.storyText, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/temple_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  storyText,
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, offset: Offset(2, 2))]),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: onContinue,
                child: Text('Continue', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
