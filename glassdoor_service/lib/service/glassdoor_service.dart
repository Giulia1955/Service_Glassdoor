import 'dart:convert';
import 'package:http/http.dart' as http;

class InvertextoService {
  static const String _token = String.fromEnvironment('KEY');

  Future<Map> searchCompany(String search) async {
    final uri = Uri.parse(
      'https://real-time-glassdoor-data.p.rapidapi.com/company-search?query=$search',
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'x-rapidapi-host': 'real-time-glassdoor-data.p.rapidapi.com',
          'x-rapidapi-key': '$_token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
        rethrow;
    }
  }
}
