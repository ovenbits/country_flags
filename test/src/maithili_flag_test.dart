import 'dart:io';
import 'dart:ui' as ui;

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jovial_svg/jovial_svg.dart';

void main() {
  test('Maithili resolves through the normal language-code constructor', () {
    expect(CountryFlag.fromLanguageCode('mai').flagCode, 'mai');
    expect(CountryFlag.fromLanguageCode('MAI').flagCode, 'mai');
  });

  testWidgets('Maithili SI preserves the supplied flag at picker aspect ratios',
      (tester) async {
    final data = await rootBundle.load('res/si/mai.si');
    final si = ScalableImage.fromSIBytes(data.buffer.asUint8List());
    expect(si.viewport, const Rect.fromLTWH(0, 0, 640, 480));
    await tester.runAsync(si.prepareImages);
    for (final size in const [Size(320, 200), Size(240, 160), Size(320, 240)]) {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: RepaintBoundary(
              key: key,
              child: SizedBox.fromSize(
                size: size,
                child: ScalableImageWidget(si: si, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final pixels = (await image.toByteData())!.buffer.asUint8List();
        var red = false;
        var green = false;
        var blue = false;
        for (var i = 0; i < pixels.length; i += 4) {
          red |= pixels[i] > 150 && pixels[i + 1] < 80 && pixels[i + 2] < 100;
          green |= pixels[i] < 80 && pixels[i + 1] > 70 && pixels[i + 2] < 100;
          blue |= pixels[i] < 80 && pixels[i + 1] < 80 && pixels[i + 2] > 100;
        }
        expect(red && green && blue, isTrue);
        final target = Platform.environment['MAITHILI_FLAG_PREVIEW'];
        if (target != null && size == const Size(320, 200)) {
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(target).writeAsBytes(png!.buffer.asUint8List());
        }
        image.dispose();
      });
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    si.unprepareImages();
  });
}
