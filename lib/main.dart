import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
   //WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyD4rt5TosvtBKw1qENsQbY9mzHhb1indWg",
      authDomain: "notesapp-66438.firebaseapp.com",
      projectId: "notesapp-66438",
      storageBucket: "notesapp-66438.appspot.com",
      messagingSenderId: "191055357956",
      appId: "1:191055357956:web:a8b0c8e61394a283abed51"
    ),
  );
  runApp(NotesApp());
}

class NotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
     // theme: ThemeData.dark(),
      title: 'Notes App',
      home: NotesForm(),
    );
  }
}

class Note {
  //String title;
  String content;
  String subject;

  Note(this.content, this.subject);
}

class NotesForm extends StatefulWidget {
  @override
  _NotesFormState createState() => _NotesFormState();
}

class _NotesFormState extends State<NotesForm> {
  final _formKey = GlobalKey<FormState>();
  //final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedSubject;
  List<Note> notes = [];

 void _addNote() async {
  if (_formKey.currentState?.validate() ?? false) {
    final content = _contentController.text.trim();
    final subject = _selectedSubject?.trim();
    
    if (content.isNotEmpty && subject!.isNotEmpty) {
      final note = Note(
        content,
        subject,
      );

      setState(() {
        notes.add(note);
        _contentController.clear();
        _selectedSubject = '';
      });

      await FirebaseFirestore.instance.collection('note').add({
        'content': note.content,
        'subject': note.subject,
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NoteListPage(notes)),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajout Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                items: [
                  DropdownMenuItem(child: Text('Java'), value: 'Java'),
                  DropdownMenuItem(child: Text('PHP'), value: 'PHP'),
                  DropdownMenuItem(child: Text('Algo'), value: 'Algo'),
                ],
                hint: Text('Selectionnez un subjet'),
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'SVP veuillez selectionnez un subjet';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'Entre la note (entre 0 et 20)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'svp veuillez entrer la note';
                  }
                  final note = int.tryParse(value);
                  if (note == null || note < 0 || note > 20) {
                    return 'SVP entrez une note comprise entre 0 et 20';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {FirebaseFirestore.instance.collection('note').add(
                  {
                    'contenu':_contentController.value.text,
                    'nom': _selectedSubject,
                    
                  }
                );
                Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NoteListPage(notes)),
            );
                },
                child: Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class NoteListPage extends StatelessWidget {
  final List<Note> notes;

  NoteListPage(this.notes);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des notes'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('note').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Une erreur s\'est produite : ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> note = document.data()! as Map<String, dynamic>;
              return ListTile(
                subtitle: Text(note['contenu']),
                trailing: Text(note['nom']),
              );
            }).toList(),
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
