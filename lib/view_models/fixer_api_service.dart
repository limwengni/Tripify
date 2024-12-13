import 'dart:convert';
import 'package:http/http.dart' as http;
class FixerApiService {
  final String apiKey = '9nAsS56vSCXW3dWZFgZf7SdOpwasuTW8';
  final String baseUrl = 'https://api.apilayer.com/exchangerates_data';

  /// Fetch the latest exchange rates.
  Future<Map<String, dynamic>> getLatestRates(
      String base, String symbols) async {
    // Build the URL with query parameters
    final String url = '$baseUrl/latest?symbols=$symbols&base=$base';

    // Set up headers
    final headers = {'apikey': apiKey};

    // Send GET request
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      // Parse and return JSON response
      return json.decode(response.body);
    } else {
      // Throw an error if the request failed
      throw Exception('Failed to load exchange rates: ${response.body}');
    }
  }

  /// Fetch all available currencies (symbols).
  Future<Map<String, String>> getAvailableCurrencies() async {
    // Build the URL for the symbols endpoint
    final String url = '$baseUrl/symbols';

    // Set up headers
    final headers = {'apikey': apiKey};

    // Send GET request
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      // Parse and return the symbols
      final jsonResponse = json.decode(response.body);
      return Map<String, String>.from(jsonResponse['symbols']);
    } else {
      // Throw an error if the request failed
      throw Exception('Failed to load available currencies: ${response.body}');
    }
  }

  /// Convert an amount from one currency to another.
  Future<double> convert(String from, String to, double amount) async {
    // Build the URL with query parameters
    final String url = '$baseUrl/convert?from=$from&to=$to&amount=$amount';

    // Set up headers
    final headers = {'apikey': apiKey};

    // Send GET request
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      // Parse and return the converted amount
      final jsonResponse = json.decode(response.body);
      return jsonResponse['result'];
    } else {
      // Throw an error if the request failed
      throw Exception('Failed to convert currency: ${response.body}');
    }
  }

  /// Fetch exchange rates for a specific date.
  Future<Map<String, dynamic>> getRatesForDate(String base, String symbols, String date) async {
    // Build the URL with query parameters
    final String url = '$baseUrl/$date?symbols=$symbols&base=$base';

    // Set up headers
    final headers = {'apikey': apiKey};

    // Send GET request
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      // Parse and return JSON response
      return json.decode(response.body);
    } else {
      // Throw an error if the request failed
      throw Exception('Failed to load exchange rates for $date: ${response.body}');
    }
  }
}
