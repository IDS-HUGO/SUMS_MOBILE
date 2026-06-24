import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sums/app.dart';

void main() {
  testWidgets('muestra la pantalla inicial de captura', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(App(prefs: prefs));

    expect(find.text('SUMS'), findsOneWidget);
    expect(find.text('Flujo de captura'), findsOneWidget);
    expect(find.text('Abrir formularios de cedula'), findsOneWidget);
  });
}
