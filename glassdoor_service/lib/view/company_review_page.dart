import 'package:flutter/material.dart';
import 'package:glassdoor_service/service/glassdoor_service.dart';
import 'package:glassdoor_service/view/widgets.dart';

class CompanyReviewPage extends StatefulWidget {
  const CompanyReviewPage({super.key});

  @override
  State<CompanyReviewPage> createState() => _CompanyReviewPageState();
}

class _CompanyReviewPageState extends State<CompanyReviewPage> {
  final _controller = TextEditingController();
  final _service = GlassodoorService();
  Future<Map<String, dynamic>>? _future;
  String? _message;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    final erro = Validador.empresaNomeOuId(value);
    if (erro != null) {
      setState(() => _message = erro);
      return;
    }
    setState(() {
      _message = null;
      _future = _service.reviewCompany(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliações da Empresa')),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Nome ou ID da empresa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Pesquisar avaliações'),
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
        'Digite o nome ou ID de uma empresa para pesquisar.',
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
        final data = asMap(root['data']);
        final reviews = asMapList(data['reviews']).isNotEmpty
            ? asMapList(data['reviews'])
            : asMapList(root['reviews']);
        if (reviews.isEmpty) {
          return stateMessage(
            'Nenhuma avaliação encontrada.',
            showPatrick: true,
          );
        }

        final notas = reviews
            .map((r) => double.tryParse(r['rating'].toString()))
            .whereType<double>()
            .toList();
        final media = notas.isEmpty
            ? null
            : notas.reduce((a, b) => a + b) / notas.length;
        final termoGif = media == null
            ? 'office work'
            : media >= 4
            ? 'celebration'
            : media >= 3
            ? 'thumbs up'
            : 'disappointed';

        return ListView(
          children: [
            GifBanner(term: termoGif),
            if (media != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Nota média: ${media.toStringAsFixed(1)} / 5',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ...reviews.map(_buildReviewCard),
          ],
        );
      },
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return resultCard(
      displayValue(review['headline'] ?? review['summary']),
      {
        'Cargo': displayValue(review['job_title']),
        'Data': displayValue(review['review_date']),
        'Avaliação': displayValue(review['rating']),
        'Recomendaria': displayValue(
          review['recommend_to_friend'] ?? review['recommendation'],
        ),
      },
      description: [review['pros'], review['cons'], review['summary']]
          .whereType<String>()
          .where((text) => text.trim().isNotEmpty)
          .join('\n\n'),
    );
  }
}
