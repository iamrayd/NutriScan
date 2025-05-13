import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  static const String apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String apiToken = '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';

  Future<String> getChatbotResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'deepseek/deepseek-chat',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 200,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content']?.trim() ?? 'Sorry, I couldn’t generate a response.';
      } else {
        return 'Error: Failed to get response from chatbot (Status: ${response.statusCode})';
      }
    } catch (e) {
      return 'Error: Failed to connect to chatbot service ($e)';
    }
  }
}