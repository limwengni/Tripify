import 'dart:convert';
import 'package:http/http.dart' as http;

class EmergencyService {
  final String baseUrl = "https://api.emergencynumberapi.com/v1/numbers";
  final String apiKey = "YOUR_API_KEY"; // Replace with your API key

  Future<Map<String, dynamic>> getEmergencyNumbers(String countryCode) async {
    final url = Uri.parse("$baseUrl?country=$countryCode");
    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $apiKey",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load emergency numbers");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
