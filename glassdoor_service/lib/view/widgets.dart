import 'package:flutter/material.dart';
import 'package:glassdoor_service/service/glassdoor_service.dart';

String displayValue(dynamic value) {
  if (value == null || value.toString().trim().isEmpty) return 'Não informado';
  return value.toString();
}

//serve para não aparecer "exception" nas mensagens de erro na tela
String errorText(Object error) =>
    error.toString().replaceFirst('Exception: ', '');

// se a imagem do patrick n existir mostra um ícone -> isso aqui foi sugestão da IA, quando estava tendo problema para carregar a imagem
Widget patrickImage({double height = 120}) {
  return Image.asset(
    'assets/patrick.png',
    height: height,
    errorBuilder: (context, error, stack) =>
        Icon(Icons.image_not_supported, size: height, color: Colors.white54),
  );
}

Widget stateMessage(
  String message, {
  bool error = false,
  bool showPatrick = false,
}) {
  final text = Text(
    message,
    textAlign: TextAlign.center,
    style: TextStyle(color: error ? Colors.red : Colors.white),
  );
  return Center(
    child: showPatrick
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [patrickImage(), const SizedBox(height: 8), text],
          )
        : text,
  );
}

Widget resultCard(
  String title,
  Map<String, String> fields, {
  String? description,
}) {
  return Card(
    color: Colors.grey[900],
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          ...fields.entries.map(
            (entry) => Text(
              '${entry.key}: ${entry.value}',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          if (description != null && description.isNotEmpty)
            Text(description, style: const TextStyle(color: Colors.white)),
        ],
      ),
    ),
  );
}

// busca uma gif mas se falhar mostra o patrick
class GifBanner extends StatefulWidget {
  final String term;
  const GifBanner({super.key, required this.term});

  @override
  State<GifBanner> createState() => _GifBannerState();
}

class _GifBannerState extends State<GifBanner> {
  late Future<String?> _future;

  @override
  void initState() {
    super.initState();
    _future = GlassodoorService().getGifUrl(widget.term);
  }

  @override
  void didUpdateWidget(GifBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    // se a pesquisa mudou busca outro gif
    if (oldWidget.term != widget.term) {
      _future = GlassodoorService().getGifUrl(widget.term);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 150,
        child: Center(
          child: FutureBuilder<String?>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              final url = snapshot.data;
              // se n tiver resultado ou der erro mostra o patrick
              if (snapshot.hasError || url == null) {
                return patrickImage(height: 150);
              }
              return Image.network(
                url,
                height: 150,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const CircularProgressIndicator(),
                errorBuilder: (context, error, stack) =>
                    patrickImage(height: 150),
              );
            },
          ),
        ),
      ),
    );
  }
}
