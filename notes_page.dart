import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  Future<void> _addNote() async {
    final titleText = _titleController.text.trim();
    final noteText = _noteController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (titleText.isEmpty || noteText.isEmpty || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both to continue')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .add({
        'title': titleText,
        'noteText': noteText,
        'createdAt': Timestamp.now(),
      });

      _titleController.clear();
      _noteController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note saved successfully!')),
      );

      Navigator.pop(context); // Go back to HomePage after saving
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving note: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF4A90E2); // Soft Blue
    final backgroundColor = Color(0xFFF5F7FA); // Light Grey Background
    final cardColor = Colors.white; // White Card Color

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Add a Note',
          style: TextStyle(color: Colors.white),
      ),

        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          color: cardColor,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: primaryColor),
                    prefixIcon: Icon(Icons.title, color: primaryColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: 'Your Note',
                    labelStyle: TextStyle(color: primaryColor),
                    prefixIcon: Icon(Icons.notes, color: primaryColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    alignLabelWithHint: true,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addNote,
                    icon: Icon(Icons.save,
                    color: Colors.white,),
                    label: Text('Save Note'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
