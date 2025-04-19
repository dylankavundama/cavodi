import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    home: TravelDiaryPage(),
  ));
}

class TravelDiaryPage extends StatefulWidget {
  const TravelDiaryPage({super.key});

  @override
  State<TravelDiaryPage> createState() => _TravelDiaryPageState();
}

class _TravelDiaryPageState extends State<TravelDiaryPage> {
  List<Map<String, dynamic>> entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('travel_entries');
    if (savedData != null) {
      final List decoded = jsonDecode(savedData);
      setState(() {
        entries = decoded
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      });
    }
  }

  Future<void> _saveEntry(Map<String, dynamic> newEntry) async {
    final prefs = await SharedPreferences.getInstance();
    entries.add(newEntry);
    await prefs.setString('travel_entries', jsonEncode(entries));
    setState(() {});
  }

  void _openAddEntryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddEntryDialog(onSave: _saveEntry);
      },
    );
  }

  Widget _buildEntryCard(Map<String, dynamic> entry) {
    final List imagePaths = entry['photos'] ?? [];

    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(entry['title']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry['date'] != null)
              Text(
                  'Date: ${DateTime.parse(entry['date']).toLocal().toString().split(' ')[0]}'),
            Text(entry['description']),
            const SizedBox(height: 8),
            Wrap(
              spacing: 5,
              children: imagePaths.map<Widget>((path) {
                return Image.file(File(path),
                    width: 80, height: 80, fit: BoxFit.cover);
              }).toList(),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carnet de Voyage')),
      body: ListView(
        children: [
          ...entries.map(_buildEntryCard).toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddEntryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
                  onPressed: _pickDate,
                  child: const Text('Choisir une date'),
                ),
                const SizedBox(width: 10),
                Text(selectedDate != null
                    ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                    : 'Aucune date')
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImages,
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler')),
        ElevatedButton(onPressed: _save, child: const Text('Enregistrer')),
      ],
    );
  }
}
