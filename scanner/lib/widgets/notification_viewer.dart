import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';

class NotificationViewScreen extends StatefulWidget {
  final String message;
  final String imagePath;

  const NotificationViewScreen({
    super.key,
    required this.message,
    required this.imagePath,
  });

  @override
  _NotificationViewScreenState createState() => _NotificationViewScreenState();
}

class _NotificationViewScreenState extends State<NotificationViewScreen> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speakMessage();
  }

  Future<void> _speakMessage() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(widget.message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reminder")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.imagePath.isNotEmpty &&
              File(widget.imagePath).existsSync())
            Image.file(File(widget.imagePath)),
          SizedBox(height: 20),
          Text(
            widget.message,
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
