import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sums/app.dart';
import 'package:sums/core/di/injection.dart';

void main() {
  testWidgets('muestra la pantalla inicial de captura', (
    WidgetTester tester,
  ) async {
    // Nombre de canal correcto de flutter_secure_storage_platform_interface
    // (antes decía 'plugins.itrix.com.br/...', que nunca existió — el mock
    // no interceptaba nada y quedó sin detectarse porque, hasta ahora, esta
    // prueba nunca disparaba una llamada real a flutter_secure_storage).
    const channel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall methodCall,
    ) async {
      if (methodCall.method == 'read') {
        return null;
      }
      return null;
    });

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Configurar dependencias
    await initInjection(prefs);

    await tester.pumpWidget(const App());

    expect(
      find.text('Cédula de Microdiagnóstico Familiar'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.text('Captura comunitaria IMSS-BIENESTAR'),
      findsAtLeastNWidgets(1),
    );
  });
}
