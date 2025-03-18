import 'dart:io';
import 'package:cms/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class AddExpensePage extends ConsumerStatefulWidget {
  final String eventId;
  final StudentModel student;

  const AddExpensePage({Key? key, required this.eventId, required this.student})
      : super(key: key);

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  File? _billImage;

  Future<void> _pickImageAndExtractText() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final inputImage = GoogleVisionImage.fromFile(File(pickedFile.path));
      final textRecognizer = GoogleVision.instance.textRecognizer();
      final visionText = await textRecognizer.processImage(inputImage);

      // Extracted text
      String extractedText = visionText.text ?? "";
      // You can now parse the extractedText to determine description and amount
      // For simplicity, let's assume the first line is the description
      // and the last line is the amount
      List<String> lines = extractedText.split('\n');
      if (lines.isNotEmpty) {
        setState(() {
          _descriptionController.text = lines.first;
          _amountController.text = lines.last;
        });
      }

      textRecognizer.close();
    }
  }

  Future<void> _pickBillImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final inputImage = GoogleVisionImage.fromFile(File(pickedFile.path));
      final textRecognizer = GoogleVision.instance.textRecognizer();
      final visionText = await textRecognizer.processImage(inputImage);

      // Extracted text
      String extractedText = visionText.text ?? "";
      // You can now parse the extractedText to determine description and amount
      // For simplicity, let's assume the first line is the description
      // and the last line is the amount
      List<String> lines = extractedText.split('\n');
      if (lines.isNotEmpty) {
        setState(() {
          _descriptionController.text = lines.first;
          _amountController.text = lines.last;
        });
      }

      textRecognizer.close();
      setState(() {
        _billImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        actions: [
          IconButton(
            icon: Icon(Icons.photo_library),
            onPressed: _pickImageAndExtractText,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Expense Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  hintText: 'Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.upload_file),
                label: const Text('Upload Bill Image'),
                onPressed: _pickBillImage,
              ),
              if (_billImage != null) ...[
                const SizedBox(height: 20),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.redAccent,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.file(
                    _billImage!,
                    height: 200,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.student.uid == null) {
          throw Exception('User not logged in');
        }

        String? billImageUrl;
        if (_billImage != null) {
          final fileName = path.basename(_billImage!.path);
          final storageRef =
              FirebaseStorage.instance.ref().child('bill_images/$fileName');
          final uploadTask = await storageRef.putFile(_billImage!);
          billImageUrl = await uploadTask.ref.getDownloadURL();
        }

        final expenseData = {
          'description': _descriptionController.text,
          'amount': double.parse(_amountController.text),
          'memberId': widget.student.uid,
          'memberName': widget.student.firstName ?? 'Unknown',
          'billImageUrl': billImageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .collection('expenses')
            .add(expenseData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Expense added successfully!')),
        );

        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add expense: $e')),
        );
      }
    }
  }
}
