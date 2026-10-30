// Test básico para ATENEA EAT
//
// Verifica que la aplicación se construye correctamente

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:atenea_eat_mobile/app.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    // Verifica que la app se construye correctamente
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verifica que la app se renderiza
    expect(find.byType(MyApp), findsOneWidget);
  });
}
