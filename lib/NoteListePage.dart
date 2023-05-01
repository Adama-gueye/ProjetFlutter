import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class Note {
  String title;
  String content;
  String subject;

  Note(this.title, this.content, this.subject);
}

class NoteListPage extends StatelessWidget {
  final List<Note> notes;

  NoteListPage(this.notes);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of Notes'),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            //title: Text(note.title),
            subtitle: Text(note.content),
            trailing: Text(note.subject),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.arrow_back),
      ),
    );
  }
}
