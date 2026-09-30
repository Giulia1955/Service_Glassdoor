import 'package:flutter_test/flutter_test.dart';
import 'package:glassdoor_service/main.dart';

void main() {
  testWidgets('shows the Glassdoor home menu', (tester) async {
    await tester.pumpWidget(const GlassdoorApp());

    expect(find.text('Glassdoor Service'), findsOneWidget);
    expect(find.text('Buscar Empresa'), findsOneWidget);
    expect(find.text('Avaliações da Empresa'), findsOneWidget);
    expect(find.text('Buscar Vagas'), findsOneWidget);
    expect(find.text('Vagas por Empresa'), findsOneWidget);
  });
}
