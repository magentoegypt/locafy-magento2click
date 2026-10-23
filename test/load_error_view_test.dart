// LoadErrorView stands in for content that failed to load, so a screen whose
// request failed says so and offers a retry instead of rendering blank. The
// home tab and the Search tab both went blank when the backend stopped
// answering in time, because every failure used to come back as an empty list
// that looked exactly like "nothing to show".
//
// It never tells anyone they have no internet. makeRequest in inspireui's
// http_client throws the same 'No Internet Connection' for a request that
// timed out and for a host that couldn't be found, and the server this was
// written against took 36s+ to answer against a 20s timeout -- so an online
// phone was being told it was offline, and sent off to fix its wifi. A
// request that got no answer now reads "couldn't reach the server", which is
// true whichever it was; one the server answered with an error reads
// "couldn't load this".

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
      // What MagentoService throws when the server answers with an error status.
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

    testWidgets('a timeout says the server was unreachable, not that the phone '
        'is offline', (tester) async {
      // What makeRequest throws on its 20s timeout -- and, identically, for a
      // failed host lookup. This is the message an online phone was shown.
      await tester.pumpWidget(_host(LoadErrorView(
        error: 'No Internet Connection',
        onRetry: () async {},
      )));
      await tester.pumpAndSettle();

      expect(
        find.text("We couldn't reach the server. Please try again."),
        findsOneWidget,
      );
      expect(find.text('No internet connection'), findsNothing);
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
