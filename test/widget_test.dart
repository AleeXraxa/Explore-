import 'package:flutter_test/flutter_test.dart';

import 'package:city_guide_app/core/constants/app_strings.dart';
import 'package:city_guide_app/main.dart';

void main() {
  testWidgets('Splash branding is visible', (WidgetTester tester) async {
    await tester.pumpWidget(const CityGuideApp());
    await tester.pump();

    expect(find.text(AppStrings.appName), findsOneWidget);
  });
}
