import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickImage});
  final void Function(File image) onPickImage;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedPicture;

  void _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage =
    await imagePicker.pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _selectedPicture = File(pickedImage.path);
    });
    widget.onPickImage(_selectedPicture!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
        onPressed: _takePicture,
        icon: const Icon(Icons.camera_alt),
        label: Text('Take Picture',style: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: Theme.of(context).colorScheme.onBackground,
        ),));
    if (_selectedPicture != null) {
      content = Image.file(
        _selectedPicture!,
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
      );
    }

    return Container(
        decoration: BoxDecoration(border: Border.all(width: 1)),
        height: 250,
        width: double.infinity,
        alignment: Alignment.center,
        child: content);
  }
}
