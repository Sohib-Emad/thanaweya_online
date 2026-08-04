// Smoke test: verifies the app builds and renders the splash screen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thanaweya_online/main.dart';

void main() {
  testWidgets('App boots to splash screen', (WidgetTester tester) async {
    // Simulate a phone-sized viewport (matches the 375x812 design size).
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // The splash screen renders a Scaffold without layout errors.
    expect(find.byType(Scaffold), findsWidgets);
    expect(tester.takeException(), isNull);

    // Dispose the tree so the splash typewriter timer / animation are
    // cancelled, then flush any remaining scheduled timers before the test ends.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 6));

    expect(tester.takeException(), isNull);
  });
}
