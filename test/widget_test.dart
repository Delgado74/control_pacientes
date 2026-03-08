import 'package:flutter_test/flutter_test.dart';
import 'package:medical_family_care/main.dart';

void main() {
  testWidgets('App inicia y muestra la pantalla de bienvenida',
      (WidgetTester tester) async {
    // Construye la app
    await tester.pumpWidget(const MedicalFamilyCareApp());

    // Verifica que aparece algún texto de la pantalla de bienvenida
    expect(find.text('Bienvenido'), findsOneWidget);
    // Cambia 'Bienvenido' por el texto exacto que uses en BienvenidaScreen
  });
}
