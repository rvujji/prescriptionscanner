import 'package:flutter/material.dart';
import 'dart:io';

class ImageViewerScreen extends StatelessWidget {
  final String imagePath;

  const ImageViewerScreen({Key? key, required this.imagePath})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescription Image')),
      body: Center(child: Image.file(File(imagePath))),
    );
  }
}
