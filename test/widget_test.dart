import 'package:flutter_test/flutter_test.dart';
import 'package:sums/app.dart';

void main() {
  testWidgets('muestra la pantalla inicial de captura', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    expect(find.text('SUMS'), findsOneWidget);
    expect(find.text('Flujo de captura'), findsOneWidget);
    expect(find.text('Abrir formularios de cedula'), findsOneWidget);
  });
}
