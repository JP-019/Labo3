import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'guest_book_message.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  StreamSubscription<QuerySnapshot>? _guestBookSubscription;
  List<GuestBookMessage> _guestBookMessages = [];
  List<GuestBookMessage> get guestBookMessages => _guestBookMessages;

  Future<DocumentReference> addMessageToGuestBook(String message) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance
        .collection('guestbook')
        .add(<String, dynamic>{
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName ?? 'Anonymous',
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  Future<void> init() async {
    // Inicializar Firebase
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    // Configurar proveedores de autenticación
    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    // Escuchar cambios en el estado del usuario
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;

        // Suscribirse a los mensajes del guestbook
        _guestBookSubscription = FirebaseFirestore.instance
            .collection('guestbook')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _guestBookMessages = [];
          for (final document in snapshot.docs) {
            _guestBookMessages.add(
              GuestBookMessage(
                name: document.data()['name'] as String,
                message: document.data()['text'] as String,
              ),
            );
          }
          notifyListeners(); // Notificar cambios para actualizar la UI
        });
      } else {
        _loggedIn = false;

        // Limpiar mensajes y cancelar suscripción
        _guestBookMessages = [];
        _guestBookSubscription?.cancel();
      }

      notifyListeners(); // Notificar cambios en el estado de inicio de sesión
    });
  }

  @override
  void dispose() {
    // Cancelar la suscripción al cerrar la app
    _guestBookSubscription?.cancel();
    super.dispose();
  }
}
