import 'dart:async';
import 'package:flutter/material.dart';
import 'guest_book_message.dart'; // Asegúrate de que este archivo esté correctamente importado.
import 'src/widgets.dart'; // Asegúrate de que StyledButton esté definido en este archivo.

class GuestBook extends StatefulWidget {
  const GuestBook({
    required this.addMessage,
    required this.messages,
    super.key,
  });

  final FutureOr<void> Function(String message) addMessage;
  final List<GuestBookMessage> messages;

  @override
  State<GuestBook> createState() => _GuestBookState();
}

class _GuestBookState extends State<GuestBook> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _isSending = false; // Controlar el estado de envío

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Usamos una función que no retorne nada
  void _sendMessage() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });

      try {
        // Esperar a que se complete el envío del mensaje
        await widget.addMessage(_controller.text);
        _controller.clear(); // Limpiar el campo de texto tras el envío
      } catch (e) {
        // Manejo de errores
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSending = false; // Restablecer el estado de envío
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Leave a message',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your message to continue';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                StyledButton(
                  onPressed: _isSending
                      ? () {}
                      : _sendMessage, // Cambié null por una función vacía cuando está deshabilitado
                  child: _isSending
                      ? const CircularProgressIndicator() // Indicador de carga
                      : Row(
                          children: const [
                            Icon(Icons.send),
                            SizedBox(width: 4),
                            Text('SEND'),
                          ],
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (widget.messages.isNotEmpty) ...[
            const Text(
              'Messages:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            // Mostrar los mensajes
            for (var message in widget.messages)
              ListTile(
                title: Text(message.name),
                subtitle: Text(message.message),
              ),
          ] else
            const Text(
              'No messages yet. Be the first to leave one!',
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
