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

    expect(find.text('Cédula de Microdiagnóstico Familiar'), findsAtLeastNWidgets(1));
    expect(find.text('Captura comunitaria IMSS-BIENESTAR'), findsAtLeastNWidgets(1));
  });
}
