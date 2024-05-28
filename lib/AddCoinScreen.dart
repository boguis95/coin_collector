import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AddCoinScreen extends StatefulWidget {
  @override
  _AddCoinScreenState createState() => _AddCoinScreenState();
}

class _AddCoinScreenState extends State<AddCoinScreen> {
  final TextEditingController yearController = TextEditingController();
  final TextEditingController rarityController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final CollectionReference coins = FirebaseFirestore.instance.collection('coins');

  File? _image;
  final picker = ImagePicker();

  // Méthode pour ouvrir la caméra et sélectionner une image
  Future<void> _pickImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Méthode pour ouvrir la galerie et sélectionner une image
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Méthode pour télécharger l'image dans Firebase Storage et obtenir l'URL de téléchargement
  Future<String> _uploadImage() async {
    if (_image == null) return '';

    String fileName = 'coins/${DateTime.now().millisecondsSinceEpoch}.png';
    Reference storageReference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = storageReference.putFile(_image!);

    try {
      await uploadTask.whenComplete(() => null);
      return await storageReference.getDownloadURL();
    } catch (e) {
      print('Upload failed: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Coin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: yearController,
                decoration: InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: rarityController,
                decoration: InputDecoration(labelText: 'Rarity'),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: valueController,
                decoration: InputDecoration(labelText: 'Value'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              _image == null
                  ? Text('No image selected.')
                  : Image.file(_image!, height: 200),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _pickImageFromCamera,
                    child: Text('Take Picture'),
                  ),
                  ElevatedButton(
                    onPressed: _pickImageFromGallery,
                    child: Text('Choose from Gallery'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final int year = int.parse(yearController.text);
                  final String rarity = rarityController.text;
                  final int quantity = int.parse(quantityController.text);
                  final double value = double.parse(valueController.text);
                  final String imageUrl = await _uploadImage();

                  coins.add({
                    'year': year,
                    'rarity': rarity,
                    'quantity': quantity,
                    'value': value,
                    'image_url': imageUrl,
                  });

                  Navigator.pop(context);
                },
                child: Text('Add Coin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}