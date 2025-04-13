import 'dart:io';

import 'package:chatup/services/bot/claude_ai_services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageAnalyzeAi extends StatefulWidget {
  const ImageAnalyzeAi({super.key});

  @override
  State<ImageAnalyzeAi> createState() => _ImageAnalyzeAiState();
}

class _ImageAnalyzeAiState extends State<ImageAnalyzeAi> {
  //variable and stuffs

  File? _image;
  String? _description;
  bool _isLoading = false;
  final _picker = ImagePicker();

  //pick image method
  Future<void> _pickImage(ImageSource sours) async {
    //pick image from gallery or camera
    try {
      final pickedFile = await _picker.pickImage(
        source: sours,
        maxHeight: 1080,
        maxWidth: 1920,
        imageQuality: 85,
      );
      //image has chosen -> start analysis
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await _analyzeImage();
      }
    }

    //error..
    catch (e) {
      print('Error picking image: $e');
    }
  }

  //analyze image method

  Future<void> _analyzeImage() async {
    if (_image == null) return; //no image chosed to analyze

    //loading..
    setState(() {
      _isLoading = true;
    });

    //start analysis of image
    try {
      final description = await ClaudeAiServices().analyzeImage(_image!);
      setState(() {
        _description = description;
      });
    }

    //error..
    catch (e) {
      print('Error analyzing image: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey,
        title: const Text('My AI'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            //display image
            margin: EdgeInsets.symmetric(
              horizontal: 20,
            ),
            height: 300,
            width: MediaQuery.of(context)
                .size
                .width, // Set the width to the screen width
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _image != null
                  ? Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    )
                  : const Center(
                      child: Text(
                        'Choose an image',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          //button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //button ->take photo
              ElevatedButton(
                onPressed: () {
                  _pickImage(ImageSource.camera);
                },
                child: const Text('Take Photo'),
              ),

              const SizedBox(
                width: 20,
              ),
              //button ->choose from gallery
              ElevatedButton(
                onPressed: () {
                  _pickImage(ImageSource.gallery);
                },
                child: const Text('Choose Photo'),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),

          //description loading..
          if (_isLoading)
            Center(child: const CircularProgressIndicator())

          //description
          else if (_description != null)
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Text(
                _description!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
