import 'dart:io';
import 'package:flutter/material.dart';

class PhotoContainer extends StatelessWidget {
  final String imagePath;

  const PhotoContainer({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        image: DecorationImage(
          image: FileImage(File(imagePath)),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
