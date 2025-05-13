import 'package:flutter/material.dart';
import '../services/chatbot_service.dart';
import '../services/firestore_service.dart';

class ChatbotScreen extends StatefulWidget {
  final List<Map<String, String>> chatHistory;

  const ChatbotScreen({super.key, required this.chatHistory});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatbotService _chatbotService = ChatbotService();
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, String>> _chatHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chatHistory = List.from(widget.chatHistory);
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _chatHistory.add({'role': 'user', 'content': _controller.text});
    });

    try {
      final userData = await _firestoreService.getUserData();

      String prompt =
          'You are a certified nutritionist. Provide  concise, evidence-based dietary advice based on what is asked by your client.\n'
          '. Use the following information as context or reference if your client asks something related to it.\n'
          ' No need to bring it up if not asked.User Allergen Profile: ${userData['allergens'].join(', ')}.\n'
          'Recently Scanned Products: ${userData['recentScans'].map((scan) => scan['productName']).join(', ')}.\n'
          'Saved Products: ${userData['savedProducts'].map((product) => product['productName']).join(', ')}.\n'
          'User Question: ${_controller.text}';


      final response = await _chatbotService.getChatbotResponse(prompt);
      setState(() {
        _chatHistory.add({'role': 'bot', 'content': response});
        _isLoading = false;
        _controller.clear();
      });
    } catch (e) {
      setState(() {
        _chatHistory.add({'role': 'bot', 'content': 'Error: Failed to fetch response ($e)'});
        _isLoading = false;
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Chatbot'),
        backgroundColor: Colors.blue[50],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  final message = _chatHistory[index];
                  return ListTile(
                    title: Text(
                      message['content']!,
                      style: TextStyle(
                        fontSize: 16,
                        color: message['role'] == 'user' ? Colors.black : Colors.blue,
                      ),
                    ),
                    leading: CircleAvatar(
                      child: Icon(message['role'] == 'user' ? Icons.person : Icons.chat),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'E.g., Give me healthy tips',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Send'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Note: This chatbot provides general advice and is not a substitute for professional medical advice.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}