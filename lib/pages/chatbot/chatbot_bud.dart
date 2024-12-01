import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'package:sprout/pages/chatbot/change_notifier.dart';
import '../../widgets/components/bottom_navigation.dart';

class BudChatbot extends StatefulWidget {
  const BudChatbot({super.key});

  @override
  _BudChatbotState createState() => _BudChatbotState();
}

class _BudChatbotState extends State<BudChatbot> {
  final TextEditingController _controller = TextEditingController();
  String? _apiKey;

  @override
  void initState() {
    super.initState();
    _fetchApiKey(); // Fetch API key on initialization
  }

  /// Fetches API keys from Firestore and selects one randomly
  Future<void> _fetchApiKey() async {
    try {
      final collection = FirebaseFirestore.instance.collection('bud_api');
      final snapshot = await collection.get();

      if (snapshot.docs.isNotEmpty) {
        final keys = snapshot.docs.map((doc) => doc['key'] as String).toList();
        final randomIndex = Random().nextInt(keys.length);
        setState(() {
          _apiKey = keys[randomIndex];
        });
      } else {
        throw Exception('No API keys found in Firestore.');
      }
    } catch (e) {
      print('Error fetching API keys: $e');
      setState(() {
        _apiKey = null;
      });
    }
  }

  Future<void> _sendMessage(BuildContext context) async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) {
      context.read<ChatState>().addMessage('Please enter a message before sending.', false);
      return;
    }

    if (_apiKey == null) {
      context.read<ChatState>().addMessage('Error: No API key available.', true);
      return;
    }

    // Add user's message and clear the text field
    context.read<ChatState>().addMessage(userMessage, false);
    _controller.clear();

    // Simulate typing effect
    context.read<ChatState>().addMessage("BUD is typing...", true);

    await Future.delayed(const Duration(seconds: 2)); // Typing delay

    final model = GenerativeModel(
      model: 'gemini-1.5-flash-002',
      apiKey: _apiKey!,
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
    );

    const initialInstructions =
        "You are BUD, a plant care expert. Answer all questions related to plant care and gardening. Do not answer any unrelated questions to your expertise. You can use emoji to make your answer more friendly.";
    final chat = model.startChat(history: [
      Content.text(initialInstructions),
    ]);

    final content = Content.text(userMessage);
    try {
      final response = await chat.sendMessage(content);
      final cleanedResponse = response.text!.replaceAll('*', '').trim();

      // Replace "BUD is typing..." with bot's response
      final chatState = context.read<ChatState>();
      chatState.messages.removeWhere((message) => message.containsValue("BUD is typing..."));
      chatState.addMessage(cleanedResponse, true);
    } catch (e) {
      final chatState = context.read<ChatState>();
      chatState.messages.removeWhere((message) => message.containsValue("BUD is typing..."));
      chatState.addMessage('Can you explain it to me again? 🌱', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<ChatState>().messages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BUD Chatbot'),
        backgroundColor: const Color.fromARGB(255, 105, 173, 108),
        centerTitle: true,
        elevation: 4,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message.containsKey('user');
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFFC1CFA1) : const Color(0xFFF1F2F3),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isUser
                            ? const Radius.circular(12)
                            : const Radius.circular(0),
                        bottomRight: isUser
                            ? const Radius.circular(0)
                            : const Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      message.values.first,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask BUD about plant care...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(context),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () => _sendMessage(context),
                  backgroundColor: const Color.fromARGB(255, 105, 173, 108),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigationBar(selectedIndex: 3),
    );
  }
}
