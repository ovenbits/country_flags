import 'dart:io';
import 'dart:ui' as ui;

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final smallFirst in [true, false]) {
    testWidgets('simultaneous Maithili flags render (small first: $smallFirst)',
        (tester) async {
      final keys = [GlobalKey(), GlobalKey()];
      await tester.pumpWidget(_flags(keys, smallFirst: smallFirst));
      await _expectColors(tester, keys);

      // Rebuilding and removing one user must not release its sibling's image.
      await tester.pumpWidget(_flags(keys, smallFirst: smallFirst));
      await _expectColors(tester, keys);
      await tester.pumpWidget(_flags([keys.last], smallFirst: smallFirst));
      await _expectColors(tester, [keys.last]);

      // A cached SI must decode again after its last prepared user is disposed.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(_flags(keys, smallFirst: smallFirst));
      await _expectColors(tester, keys);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('flags can be replaced and disposed while decoding',
      (tester) async {
    final keys = [GlobalKey(), GlobalKey()];
    await tester.pumpWidget(_flags(keys));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_flags(keys, language: 'en'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(_flags(keys));
    await _expectColors(tester, keys);
    expect(tester.takeException(), isNull);
  });
}

Widget _flags(
  List<GlobalKey> keys, {
  bool smallFirst = true,
  String language = 'mai',
}) {
  return MaterialApp(
    home: Column(
      children: [
        for (var i = 0; i < keys.length; i++)
          RepaintBoundary(
            key: keys[i],
            child: CountryFlag.fromLanguageCode(
              language,
              width: (i == 0) == smallFirst ? 32 : 320,
              height: (i == 0) == smallFirst ? 20 : 240,
            ),
          ),
      ],
    ),
  );
}

Future<void> _expectColors(WidgetTester tester, List<GlobalKey> keys) async {
  // Settle widget frames before allowing real embedded-PNG decoding. This
  // exercises the concurrent preparation race instead of preloading the SI.
  await tester.pumpAndSettle();
  var colors = <List<bool>>[];
  for (var attempt = 0; attempt < 100; attempt++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
    colors = await tester.runAsync(() async {
          final result = <List<bool>>[];
          for (final key in keys) {
            final boundary = key.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
            final image = await boundary.toImage();
            final bytes = (await image.toByteData())!.buffer.asUint8List();
            var red = false;
            var green = false;
            var blue = false;
            for (var i = 0; i < bytes.length; i += 4) {
              red |= bytes[i] > 150 && bytes[i + 1] < 80 && bytes[i + 2] < 100;
              green |= bytes[i] < 80 && bytes[i + 1] > 70 && bytes[i + 2] < 100;
              blue |= bytes[i] < 80 && bytes[i + 1] < 80 && bytes[i + 2] > 100;
            }
            result.add([red, green, blue]);
            final target = Platform.environment['FLAG_EVIDENCE'];
            if (target != null) {
              final png =
                  await image.toByteData(format: ui.ImageByteFormat.png);
              await File('$target-${keys.indexOf(key)}.png')
                  .writeAsBytes(png!.buffer.asUint8List());
            }
            image.dispose();
          }
          return result;
        }) ??
        [];
    if (colors.length == keys.length &&
        colors.every((flags) => flags.every((value) => value))) {
      break;
    }
  }
  expect(
    colors,
    [
      for (final _ in keys) [true, true, true],
    ],
    reason:
        'Maithili flag must render its original red, green and blue regions '
        'in every instance',
  );
}
