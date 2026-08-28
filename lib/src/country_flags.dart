import 'package:country_flags/country_flags.dart';
import 'package:country_flags/src/flags_clipper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jovial_svg/jovial_svg.dart';

/// The shape of the flag.
sealed class Shape {
  const Shape();
}

/// Rectangular shape.
class Rectangle extends Shape {
  /// Create an instance of [Rectangle].
  const Rectangle();
}

/// Circular shape.
class Circle extends Shape {
  /// Create an instance of [Circle].
  const Circle();
}

/// Rectangular shape with rounded corners.
class RoundedRectangle extends Shape {
  /// Create an instance of [RoundedRectangle].
  const RoundedRectangle(this.borderRadius);

  /// The border radius of the corners of the rectangle.
  final double borderRadius;
}

/// {@template country_flags}
/// A widget that displays a country flag.
/// {@endtemplate}
class CountryFlag extends StatelessWidget {
  /// Create an instance of [CountryFlag] based on a language.
  ///
  /// {@macro country_flags}
  CountryFlag.fromLanguageCode(
    String languageCode, {
    Shape shape = const Rectangle(),
    Key? key,
    double? height,
    double? width,
  }) : this._(
          key: key,
          flagCode: FlagCode.fromLanguageCode(languageCode.toLowerCase()),
          width: width,
          height: height,
          shape: shape,
        );

  /// Create an instance of [CountryFlag] based on a country code.
  ///
  /// {@macro country_flags}
  CountryFlag.fromCountryCode(
    String countryCode, {
    Shape shape = const Rectangle(),
    double? height,
    double? width,
    Key? key,
  }) : this._(
          key: key,
          flagCode: FlagCode.fromCountryCode(countryCode.toUpperCase()),
          width: width,
          height: height,
          shape: shape,
        );

  /// {@macro country_flags}
  const CountryFlag._({
    required this.shape,
    super.key,
    this.flagCode,
    this.width,
    this.height,
  });

  /// The country ISO code of the flag to display.
  ///
  /// The list of country codes can be found here: https://www.iban.com/country-codes.
  final String? flagCode;

  /// The height of the flag.
  final double? height;

  /// The width of the flag.
  final double? width;

  /// The flag shape: 'circle' or 'rectangle'.
  final Shape shape;

  List<String> get _additionalFlags => const [
        'ce',
        'hmn',
        'kaa',
        'ber',
        'ku',
        'mas',
        'os',
        'ug_cn',
        'glk',
      ];

  List<String> get _customEnglishFlag => const [
        'en',
        'us',
        'gb',
      ];

  @override
  Widget build(BuildContext context) {
    if (_customEnglishFlag.contains(flagCode?.toLowerCase())) {
      return Stack(
        children: [
          SizedBox(
            width: width,
            height: height,
            child: SvgPicture.asset(
              'packages/country_flags/res/svg/gb.svg',
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(
            width: width,
            height: height,
            child: DecoratedBox(
              decoration: const BoxDecoration(),
              child: ClipPath(
                clipper: FlagsClipper(),
                child: SvgPicture.asset(
                  'packages/country_flags/res/svg/us.svg',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (flagCode?.toLowerCase() == 'tz_ke') {
      return Stack(
        children: [
          SizedBox(
            width: width,
            height: height,
            child: SvgPicture.asset(
              'packages/country_flags/res/svg/tz.svg',
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(
            width: width,
            height: height,
            child: DecoratedBox(
              decoration: const BoxDecoration(),
              child: ClipPath(
                clipper: FlagsClipper(),
                child: SvgPicture.asset(
                  'packages/country_flags/res/svg/ke.svg',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (_additionalFlags.contains(flagCode?.toLowerCase())) {
      return SizedBox(
        width: width,
        height: height,
        child: SvgPicture.asset(
          'packages/country_flags/res/svg/$flagCode.svg',
        ),
      );
    }
    return switch (shape) {
      Rectangle() => _RectangularFlag(
          flagCode: flagCode,
          width: width,
          height: height,
        ),
      Circle() => _CircularFlag(
          flagCode: flagCode,
          width: width,
          height: width,
        ),
      RoundedRectangle(:final borderRadius) => _RoundedRectangularFlag(
          borderRadius: borderRadius,
          width: width,
          height: height,
          flagCode: flagCode,
        ),
    };
  }
}

class _RectangularFlag extends StatelessWidget {
  const _RectangularFlag({
    this.flagCode,
    double? width,
    double? height,
  })  : _width = width ?? 60,
        _height = height ?? 40;

  final String? flagCode;
  final double _width;
  final double _height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: _height,
      child: flagCode != null
          ? _FlagImage(
              flagCode: flagCode,
              fit: BoxFit.cover,
            )
          : const _NotFoundFlag(),
    );
  }
}

class _CircularFlag extends StatelessWidget {
  const _CircularFlag({
    this.flagCode,
    double? width,
    double? height,
  })  : _width = width ?? 40,
        _height = height ?? 40;

  final String? flagCode;
  final double _width;
  final double _height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('countryFlags_CircularFlag_SizedBox'),
      width: _width,
      height: _height,
      child: ClipOval(
        child: flagCode != null
            ? _FlagImage(
                flagCode: flagCode,
                fit: BoxFit.cover,
              )
            : const _NotFoundFlag(),
      ),
    );
  }
}

class _RoundedRectangularFlag extends StatelessWidget {
  const _RoundedRectangularFlag({
    required this.borderRadius,
    this.flagCode,
    double? width,
    double? height,
  })  : _width = width ?? 60,
        _height = height ?? 40;

  final String? flagCode;
  final double _width;
  final double _height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        key: const Key('countryFlags_RoundedRectangularFlag_SizedBox'),
        width: _width,
        height: _height,
        child: flagCode != null
            ? _FlagImage(
                flagCode: flagCode,
                fit: BoxFit.cover,
              )
            : const _NotFoundFlag(),
      ),
    );
  }
}

class _NotFoundFlag extends StatelessWidget {
  const _NotFoundFlag();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.white,
      child: Center(
        child: Icon(Icons.question_mark),
      ),
    );
  }
}

class _FlagImage extends StatelessWidget {
  const _FlagImage({
    this.flagCode,
    this.fit = BoxFit.contain,
  });

  /// Retains parsed flags across widget rebuilds.
  ///
  /// Without a cache, [ScalableImageWidget.fromSISource] falls back to a
  /// zero-size default, so a flag scrolling out of view is evicted at once and
  /// re-parsed when it scrolls back. On Flutter web (Skwasm) that eviction also
  /// releases native `Path` objects that queued pictures still reference, which
  /// crashes the renderer with "memory access out of bounds". Sized to hold
  /// every flag in the pack.
  static final _cache = ScalableImageCache(size: 300);

  final BoxFit fit;
  final String? flagCode;

  @override
  Widget build(BuildContext context) {
    return ScalableImageWidget.fromSISource(
      key: const Key('svgFlag'),
      cache: _cache,
      si: ScalableImageSource.fromSI(
        rootBundle,
        'packages/country_flags/res/si/$flagCode.si',
      ),
      fit: fit,
    );
  }
}
