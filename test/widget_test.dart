import 'package:bg_remover/app.dart';
import 'package:bg_remover/core/di/injection_container.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await initDependencies();
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('BgRemoverApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BgRemoverApp());
    expect(find.byType(BgRemoverApp), findsOneWidget);
  });
}
