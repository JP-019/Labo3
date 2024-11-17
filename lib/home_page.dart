import 'package:firebase_auth/firebase_auth.dart'; // Importa FirebaseAuth
import 'package:flutter/material.dart';
import 'package:gtk_flutter/guest_book.dart';
import 'package:gtk_flutter/guest_book_message.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'src/authentication.dart';
import 'src/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<GuestBookMessage> messages = []; // Lista para almacenar los mensajes

  // Función para agregar mensajes a la lista
  void addMessage(String message) {
    final user = FirebaseAuth.instance.currentUser; // Obtener el usuario actual

    // Verifica si el usuario está autenticado y obtén su nombre
    final userName = user?.displayName ??
        user?.email ??
        'Anonymous'; // Usa el displayName o el email

    setState(() {
      // Crear un objeto GuestBookMessage con el nombre del usuario y agregarlo a la lista
      messages.add(GuestBookMessage(name: userName, message: message));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Meetup'),
      ),
      body: ListView(
        children: <Widget>[
          Image.asset('assets/codelab.png'),
          const SizedBox(height: 8),
          const IconAndDetail(Icons.calendar_today, 'October 30'),
          const IconAndDetail(Icons.location_city, 'San Francisco'),
          // Agregar desde aquí
          Consumer<ApplicationState>(
            builder: (context, appState, _) => AuthFunc(
                loggedIn: appState.loggedIn,
                signOut: () {
                  FirebaseAuth.instance.signOut();
                }),
          ),
          const Divider(
            height: 8,
            thickness: 1,
            indent: 8,
            endIndent: 8,
            color: Colors.grey,
          ),
          const Header("What we'll be doing"),
          const Paragraph(
            'Join us for a day full of Firebase Workshops and Pizza!',
          ),
          const Header('Discussion'),
          GuestBook(
            addMessage: (message) {
              print("Mensaje recibido: $message");
              addMessage(message); // Usamos la función para agregar el mensaje
            },
            messages:
                messages, // Pasa la lista de mensajes como GuestBookMessage
          ),
        ],
      ),
    );
  }
}
