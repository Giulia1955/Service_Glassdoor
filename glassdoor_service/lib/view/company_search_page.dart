import 'package:flutter/material.dart';
import 'package:glassdoor_service/service/glassdoor_service.dart';
import 'package:glassdoor_service/view/widgets.dart';

class CompanySearchPage extends StatefulWidget {
  const CompanySearchPage({super.key});

  @override
  State<CompanySearchPage> createState() => _CompanySearchPageState();
}

class _CompanySearchPageState extends State<CompanySearchPage> {
  final _controller = TextEditingController();
  final _service = GlassodoorService();
  Future<Map<String, dynamic>>? _future;
  String? _message;
  String _term = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    final erro = Validador.termoBusca(value, 'Nome da empresa');
    if (erro != null) {
      setState(() => _message = erro);
      return;
    }
    setState(() {
      _message = null;
      _term = value;
      _future = _service.searchCompany(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Empresa')),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Nome da empresa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Pesquisar'),
              ),
            ),
            if (_message != null) stateMessage(_message!, error: true),
            const SizedBox(height: 8),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_future == null) {
      return stateMessage(
        'Digite o nome de uma empresa para pesquisar.',
        showPatrick: true,
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return stateMessage(errorText(snapshot.error!), error: true);
        }

        final root = asMap(snapshot.data);
        final companies = GlassodoorService.empresasDe(root);
        if (companies.isEmpty) {
          return stateMessage('Nenhuma empresa encontrada.', showPatrick: true);
        }

        return ListView(
          children: [
            GifBanner(term: _term),
            ...companies.map(_buildCompanyCard),
          ],
        );
      },
    );
  }

  Widget _buildCompanyCard(Map<String, dynamic> company) {
    return resultCard(
      displayValue(company['name'] ?? company['company_name']),
      {
        'Local': displayValue(
          company['location'] ?? company['city'] ?? company['state'],
        ),
        'Avaliação': displayValue(company['rating']),
        'ID': displayValue(company['company_id'] ?? company['id']),
      },
      description: company['description']?.toString(),
    );
  }
}
