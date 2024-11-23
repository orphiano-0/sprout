import 'package:flutter/material.dart';

class ChatState extends ChangeNotifier {
  final List<Map<String, String>> _messages = [];

  List<Map<String, String>> get messages => _messages;

  void addMessage(String message, bool isBud) {
    _messages.add({isBud ? 'bud' : 'user': message});
    notifyListeners();
  }
}
