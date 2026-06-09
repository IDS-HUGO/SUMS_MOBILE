import 'package:flutter_test/flutter_test.dart';
import 'package:sums/app.dart';

void main() {
  testWidgets('muestra la pantalla de login', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Iniciar sesion'), findsOneWidget);
    expect(find.text('Nombre de usuario'), findsOneWidget);
    expect(find.text('Contrasena'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
