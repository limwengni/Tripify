import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatModel {
  Future<String> sendMessageToApi(String message, int userId) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/api/message'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'message': message, 'user_id': userId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['response'];
    } else {
      throw Exception('Failed to load response');
    }
  }

  // Optional: Add fetchPrompts method if prompts are needed
  // Future<List<String>> fetchPrompts() async {
  //   final response = await http.get(Uri.parse('http://127.0.0.1:5000/api/prompts'));
  //   if (response.statusCode == 200) {
  //     return List<String>.from(jsonDecode(response.body));
  //   } else {
  //     throw Exception('Failed to load prompts');
  //   }
  // }
}
