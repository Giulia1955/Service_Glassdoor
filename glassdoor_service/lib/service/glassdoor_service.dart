import 'dart:convert';
import 'package:http/http.dart' as http;

class InvertextoService {
  static const String _token = String.fromEnvironment('GLASSDOOR_KEY');
  static const String _key = String.fromEnvironment('GIPHY_KEY');

  Future<Map<String, dynamic>> getGifs(String search) async {
    if (_key.isEmpty) {
      throw Exception(
        'Token do Giphy não configurado. Rode com --dart-define=GIPHY_KEY=...',
      );
    }
    http.Response response;

    final uri = Uri.parse(
      "https://api.giphy.com/v1/gifs/search?api_key=$_key&limit=1&q=$query",
    );


    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'].isNotEmpty) {
            return data;
        }
        return {};
      } else {
        throw Exception('Erro ao buscar GIF: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }


  // Company search
  Future<Map<String, dynamic>> searchCompany(String search) async {
    if (_token.isEmpty) {
      throw Exception(
        'Token não configurado. Rode com --dart-define=GLASSDOOR_KEY=...',
      );
    }

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

  // Company review
  Future<Map<String, dynamic>> reviewCompany(String search) async {
   if (_token.isEmpty) {
      throw Exception(
        'Token não configurado. Rode com --dart-define=GLASSDOOR_KEY=...',
      );
    }

    final uri = Uri.parse(
      'https://real-time-glassdoor-data.p.rapidapi.com/company-reviews?company_id=$search',
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

  // Job search
  Future<Map<String, dynamic>> jobSearch(String search, bool? remote_only, String? min_company_rating, bool? easy_apply_only, String? location_type, String location) async {
    if (_token.isEmpty) {
      throw Exception(
        'Token não configurado. Rode com --dart-define=GLASSDOOR_KEY=...',
      );
    }

    final uri = Uri.parse(
      'https://real-time-glassdoor-data.p.rapidapi.com/job-search?remote_only=$remote_only&min_company_rating=$min_company_rating&easy_apply_only=$easy_apply_only&location_type=$location_type&location=$location&query=$search',
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

  // company jobs
  Future<Map<String, dynamic>> companyjobs(String? job_function, int? max_age_days, String? location_type, String? sort, String search) async {
    if (_token.isEmpty) {
      throw Exception(
        'Token não configurado. Rode com --dart-define=GLASSDOOR_KEY=...',
      );
    }

    final uri = Uri.parse(
      'https://real-time-glassdoor-data.p.rapidapi.com/company-jobs?job_function=$job_function&max_age_days=$max_age_days&location_type=$location_type&sort=$sort&company_id=$search',
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
