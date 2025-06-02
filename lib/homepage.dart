import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'notes_page.dart';
import 'auth_screen.dart';

class HomePage extends StatelessWidget {
  final Color primaryColor = const Color(0xFF4A90E2); // Soft Blue
  final Color backgroundColor = const Color(0xFFF5F7FA); // Light background
  final Color cardColor = const Color(0xFFFFFFFF); // Pure white
  final Color textColor = const Color(0xFF2C3E50); // Soft dark text

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('My Notes App',
            style: TextStyle(color: Colors.white)
        ),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.logout,
            color: Colors.white,),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
            },
          ),
        ],
      ),
      body: user == null
          ? Center(child: Text('User not logged in', style: TextStyle(color: textColor)))
          : Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotesPage()),
                );
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                'Create New Note',
                style: TextStyle(color: Colors.white), // 👈 explicitly set text color
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(vertical: 14,horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('notes')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: \${snapshot.error}', style: TextStyle(color: textColor)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final notes = snapshot.data!.docs;

                if (notes.isEmpty) {
                  return Center(child: Text('No notes found.', style: TextStyle(color: textColor)));
                }

                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final title = note['title'] ?? 'No Title';
                    final text = note['noteText'] ?? '';
                    final createdAt = note['createdAt']?.toDate();

                    return Card(
                      color: cardColor,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: primaryColor,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(text, style: TextStyle(color: textColor)),
                            SizedBox(height: 6),
                            if (createdAt != null)
                              Text(
                                '${createdAt.day}/${createdAt.month}/${createdAt.year} - ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              )
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _showEditDialog(context, note),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteNote(context, note),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, DocumentSnapshot note) {
    final titleController = TextEditingController(text: note['title']);
    final textController = TextEditingController(text: note['noteText']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: textController,
                decoration: InputDecoration(labelText: 'Note'),
                maxLines: null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await note.reference.update({
                  'title': titleController.text.trim(),
                  'noteText': textController.text.trim(),
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(BuildContext context, DocumentSnapshot note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Note'),
        content: Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await note.reference.delete();
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
