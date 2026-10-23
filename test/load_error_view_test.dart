// LoadErrorView stands in for content that failed to load, so a screen whose
// request failed says so and offers a retry instead of rendering blank. The
// home tab and the Search tab both went blank when the backend refused this
// network with a 403, because every failure used to come back as an empty list
// that looked exactly like "nothing to show".
//
// The message rides on the same isNoInternetError contract that
// test/no_internet_error_test.dart pins: a request that never left the device
// says "No internet connection", and anything else -- a server that answered
// but refused, an error status -- gets the general message. Telling someone
// whose connection is fine that they have no internet sends them off to fix
// the wrong thing, which is the case the first test guards.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magentoegypt/generated/l10n.dart';
import 'package:magentoegypt/widgets/common/load_error_view.dart';

Widget _host(Widget child) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('LoadErrorView', () {
    testWidgets('a refused request does not claim there is no internet',
        (tester) async {
      // What MagentoService throws for the 403 this was written against.
      await tester.pumpWidget(_host(LoadErrorView(
        error: 'Categories request failed: HTTP 403',
        onRetry: () async {},
      )));
      await tester.pumpAndSettle();

      expect(
        find.text("We couldn't load this right now. Please try again."),
        findsOneWidget,
      );
      expect(find.text('No internet connection'), findsNothing);
    });

    testWidgets('a request that never left the device says so',
        (tester) async {
      // What makeRequest in inspireui's http_client throws for a dropped
      // socket.
      await tester.pumpWidget(_host(LoadErrorView(
        error: 'No Internet Connection',
        onRetry: () async {},
      )));
      await tester.pumpAndSettle();

      expect(find.text('No internet connection'), findsOneWidget);
    });

    testWidgets('retry re-issues the request and survives it failing again',
        (tester) async {
      var calls = 0;
      await tester.pumpWidget(_host(LoadErrorView(
        error: 'Homepage sections request failed: HTTP 403',
        onRetry: () async {
          calls++;
          // ignore: only_throw_errors
          throw 'Homepage sections request failed: HTTP 403';
        },
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(calls, 1);
      // Back to offering a retry -- not stuck on the spinner, and the second
      // failure did not escape the widget.
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
