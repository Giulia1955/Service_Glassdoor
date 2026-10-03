import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

Map<String, dynamic> asMap(dynamic value) {
  return value is Map ? Map<String, dynamic>.from(value) : {};
}

List<Map<String, dynamic>> asMapList(dynamic value) {
  if (value is! List) return [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

class Validador {
  // meio geral para campos vazios
  static String? vazio(String? valor, [String msg = 'Campo obrigatório']) {
    if (valor == null || valor.trim().isEmpty) return msg;
    return null;
  }

  // meio geral, bloqueia buscas inuteis tipo "a"
  static String? termoBusca(String? valor, [String campo = 'Termo de busca']) {
    if (valor == null || valor.trim().isEmpty) return '$campo é obrigatório';
    if (valor.trim().length < 2) {
      return '$campo deve ter ao menos 2 caracteres';
    }
    return null;
  }

  // garante que ID é num
  static String? companyId(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'ID da empresa é obrigatório';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(valor.trim())) {
      return 'ID da empresa inválido (esperado apenas números)';
    }
    return null;
  }

  // company rating da api aceita 1 a 5 ou vazio
  static String? rating(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    final n = int.tryParse(valor.trim());
    if (n == null || n < 1 || n > 5) {
      return 'Avaliação mínima deve ser um número entre 1 e 5';
    }
    return null;
  }

  // location_type aceita CITY, STATE ou COUNTRY ou vazio
  static String? locationType(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    const validos = {'CITY', 'STATE', 'COUNTRY'};
    if (!validos.contains(valor.trim().toUpperCase())) {
      return 'Tipo de localização inválido (use CITY, STATE ou COUNTRY)';
    }
    return null;
  }

  // max_age_days tem que ser positivo
  static String? maxAgeDias(int? valor) {
    if (valor == null) return null;
    if (valor < 1 || valor > 365) {
      return 'Idade máxima da vaga deve ser entre 1 e 365 dias';
    }
    return null;
  }

  // location é obrigatória quando o usuário faz busca de vagas
  static String? location(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Localização é obrigatória';
    }
    return null;
  }

  static String? empresaNomeOuId(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Nome ou ID da empresa é obrigatório';
    }
    if (RegExp(r'^[0-9]+$').hasMatch(valor.trim())) return null;
    if (valor.trim().length < 2) {
      return 'Nome da empresa deve ter ao menos 2 caracteres';
    }
    return null;
  }
}

class GlassodoorService {
  static const String _token = String.fromEnvironment('GLASSDOOR_KEY');
  static const String _key = String.fromEnvironment('GIPHY_KEY');

  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, dynamic> params,
  ) async {
    if (_token.isEmpty) {
      throw Exception(
        'Token não configurado. Rode com --dart-define=GLASSDOOR_KEY=...',
      );
    }

    //para enviar parâmetros n nulos para trratar vazio
    final query = <String, String>{
      for (final e in params.entries)
        if (e.value != null) e.key: e.value.toString(),
    };
    final uri = Uri.https(
      'real-time-glassdoor-data.p.rapidapi.com',
      path,
      query,
    );
    print('REQUISIÇÃO: $uri');

    final response = await http.get(
      uri,
      headers: {
        'x-rapidapi-host': 'real-time-glassdoor-data.p.rapidapi.com',
        'x-rapidapi-key': _token,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Erro ${response.statusCode}: ${response.body}');
  }

  // extrai a lista de empresas
  static List<Map<String, dynamic>> empresasDe(Map<String, dynamic> root) {
    final data = root['data'];
    final results = asMapList(data).isNotEmpty
        ? asMapList(data)
        : asMapList(asMap(data)['companies']);
    return results.isNotEmpty ? results : asMapList(root['companies']);
  }

  // se for num é id, se não descobre nome pelo ID
  Future<String> resolveCompanyId(String entrada) async {
    final texto = entrada.trim();
    if (RegExp(r'^[0-9]+$').hasMatch(texto)) return texto;

    final empresas = empresasDe(await searchCompany(texto));
    if (empresas.isEmpty) {
      throw Exception('Nenhuma empresa encontrada com o nome "$texto".');
    }
    final id = empresas.first['company_id'] ?? empresas.first['id'];
    if (id == null) {
      throw Exception('A API não retornou o ID da empresa "$texto".');
    }
    return id.toString();
  }

  Future<Map<String, dynamic>> getGifs(String search) async {
    final erro = Validador.termoBusca(search, 'Termo de busca do GIF');
    if (erro != null) throw Exception(erro);

    if (_key.isEmpty) {
      throw Exception(
        'Token do Giphy não configurado. Rode com --dart-define=GIPHY_KEY=...',
      );
    }

    final uri = Uri.https('api.giphy.com', '/v1/gifs/search', {
      'api_key': _key,
      'limit': '10',
      'q': search,
    });

    final response = await http.get(uri); // ALTERADO: sem try/catch inútil

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'].isNotEmpty) {
        return data;
      }
      return {};
    } else {
      throw Exception('Erro ao buscar GIF: ${response.statusCode}');
    }
  }

  //pega a url do gif sorteado entre os 10 primeiro ou nulo
  Future<String?> getGifUrl(String termo) async {
    final gifs = await getGifs(termo);
    final lista = asMapList(gifs['data']).take(10).toList();
    if (lista.isEmpty) return null;
    final gif = lista[Random().nextInt(lista.length)];
    return asMap(asMap(gif['images'])['fixed_height'])['url']?.toString();
  }

  // Company search
  Future<Map<String, dynamic>> searchCompany(String search) async {
    final erro = Validador.termoBusca(search, 'Nome da empresa');
    if (erro != null) throw Exception(erro);

    return _get('/company-search', {'query': search});
  }

  // Company review
  Future<Map<String, dynamic>> reviewCompany(String search) async {
    final erro = Validador.empresaNomeOuId(search);
    if (erro != null) throw Exception(erro);

    final id = search.trim();
    return _get('/company-reviews', {'company_id': id});
  }

  // Job search
  Future<Map<String, dynamic>> jobSearch(
    String search,
    bool? remote_only,
    String? min_company_rating,
    bool? easy_apply_only,
    String? location_type,
    String location,
  ) async {
    final erroTermo = Validador.termoBusca(search, 'Cargo/termo da vaga');
    if (erroTermo != null) throw Exception(erroTermo);

    final erroLocal = Validador.location(location);
    if (erroLocal != null) throw Exception(erroLocal);

    final erroTipoLocal = Validador.locationType(location_type);
    if (erroTipoLocal != null) throw Exception(erroTipoLocal);

    final erroRating = Validador.rating(min_company_rating);
    if (erroRating != null) throw Exception(erroRating);

    return _get('/job-search', {
      'remote_only': remote_only,
      'min_company_rating': min_company_rating,
      'easy_apply_only': easy_apply_only,
      'location_type': location_type,
      'location': location,
      'query': search,
    });
  }

  // company jobs
  Future<Map<String, dynamic>> companyjobs(
    String? job_function,
    int? max_age_days,
    String? location_type,
    String? sort,
    String search,
  ) async {
    final erroId = Validador.empresaNomeOuId(search);
    if (erroId != null) throw Exception(erroId);

    final erroIdade = Validador.maxAgeDias(max_age_days);
    if (erroIdade != null) throw Exception(erroIdade);

    final erroTipoLocal = Validador.locationType(
      location_type,
    );
    if (erroTipoLocal != null) throw Exception(erroTipoLocal);

    final id = await resolveCompanyId(search);
    return _get('/company-jobs', {
      'job_function': job_function,
      'max_age_days': max_age_days,
      'location_type': location_type,
      'sort': sort,
      'company_id': id,
    });
  }
}
