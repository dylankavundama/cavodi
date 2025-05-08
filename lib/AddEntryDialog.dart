


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AddEntryDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const AddEntryDialog({super.key, required this.onSave});

  @override
  State<AddEntryDialog> createState() => _AddEntryDialogState();
}

class _AddEntryDialogState extends State<AddEntryDialog> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;
  List<File> photos = [];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        photos = pickedFiles.take(3).map((x) => File(x.path)).toList();
      });
    }
  }

  Future<void> _save() async {
    List<String> imagePaths = [];
    for (File photo in photos) {
      final dir = await getApplicationDocumentsDirectory();
      final filename = '${DateTime.now().millisecondsSinceEpoch}.png';
      final saved = await photo.copy('${dir.path}/$filename');
      imagePaths.add(saved.path);
    }

    final newEntry = {
      'title': titleController.text,
      'description': descriptionController.text,
      'date': selectedDate?.toIso8601String() ?? '',
      'photos': imagePaths,
    };

    widget.onSave(newEntry);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle entrée'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            TextField(
              controller: descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF80B4FB), // Couleur personnalisée
                    foregroundColor: Colors.white, // Couleur du texte
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _pickDate,
                  child: const Text('Choisir une date'),
                ),
                const SizedBox(width: 10),
                Text(selectedDate != null
                    ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                    : '')
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImages,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF80B4FB), // Couleur personnalisée
                foregroundColor: Colors.white, // Couleur du texte
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Ajouter des photos'),
            ),
            Wrap(
              spacing: 5,
              children: photos
                  .map((file) => Image.file(file,
                      width: 70, height: 70, fit: BoxFit.cover))
                  .toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade300, // Couleur personnalisée
            foregroundColor: Colors.white, // Couleur du texte
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF80B4FB), // Couleur personnalisée
              foregroundColor: Colors.white, // Couleur du texte
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _save,
            child: const Text('Enregistrer')),
      ],
    );
  }
}

