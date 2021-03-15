import 'package:meta/meta.dart';
import '../color_model.dart';
import '../helpers/color_adjustments.dart';
import '../helpers/color_converter.dart';
import '../helpers/color_math.dart';

// TODO: Expand XYZ to allow for custom whitepoints.

/// A color in the CIEXYZ color space.
@immutable
class XyzColor extends ColorModel {
  /// A color in the CIEXYZ color space.
  ///
  /// [x], [y], and [z] must all be `>= 0`.
  ///
  /// [alpha] must be `>= 0` and `<= 1`.
  ///
  /// The XYZ values have been normalized to a 0 to 100 range that
  /// represents the whole of the sRGB color space, but have been
  /// left upwardly unbounded to allow to allow for conversions
  /// between the XYZ and LAB color spaces that fall outside of
  /// the sRGB color space's bounds.
  const XyzColor(
    this.x,
    this.y,
    this.z, [
    int alpha = 255,
  ])  : assert(x >= 0),
        assert(y >= 0),
        assert(z >= 0),
        assert(alpha >= 0 && alpha <= 255),
        super(alpha: alpha);

  /// The x value of this color.
  ///
  /// Ranges from `0` to `100` in the normal sRGB spectrum, but colors
  /// outside of the sRGB spectrum are upwardly unbounded.
  final num x;

  /// The y value of this color.
  ///
  /// Ranges from `0` to `100` in the normal sRGB spectrum, but colors
  /// outside of the sRGB spectrum are upwardly unbounded.
  final num y;

  /// The x value of this color.
  ///
  /// Ranges from `0` to `100` in the normal sRGB spectrum, but colors
  /// outside of the sRGB spectrum are upwardly unbounded.
  final num z;

  @override
  bool get isBlack =>
      ColorMath.round(x) == 0 &&
      ColorMath.round(y) == 0 &&
      ColorMath.round(z) == 0;

  @override
  bool get isWhite =>
      ColorMath.round(x) >= 100 &&
      ColorMath.round(y) >= 100 &&
      ColorMath.round(z) >= 100;

  @override
  bool get isMonochromatic {
    final x = ColorMath.round(this.x);
    return x == ColorMath.round(y) && x == ColorMath.round(z);
  }

  @override
  XyzColor interpolate(ColorModel end, double step) {
    assert(step >= 0.0 && step <= 1.0);
    return super.interpolate(end, step) as XyzColor;
  }

  @override
  List<XyzColor> lerpTo(
    ColorModel color,
    int steps, {
    bool excludeOriginalColors = false,
  }) {
    assert(steps > 0);
    return super
        .lerpTo(color, steps, excludeOriginalColors: excludeOriginalColors)
        .cast<XyzColor>();
  }

  @override
  XyzColor get inverted {
    final values = toList();

    return XyzColor.fromList(
        List<num>.generate(values.length, (i) => 100 - values[i].clamp(0, 100))
          ..add(alpha));
  }

  @override
  XyzColor get opposite => rotateHue(180);

  @override
  XyzColor rotateHue(num amount) =>
      ColorAdjustments.rotateHue(this, amount).toXyzColor();

  @override
  XyzColor warmer(num amount, {bool relative = true}) {
    assert(amount > 0);
    return ColorAdjustments.warmer(this, amount, relative: relative)
        .toXyzColor();
  }

  @override
  XyzColor cooler(num amount, {bool relative = true}) {
    assert(amount > 0);
    return ColorAdjustments.cooler(this, amount, relative: relative)
        .toXyzColor();
  }

  /// Returns this [XyzColor] modified with the provided [hue] value.
  @override
  XyzColor withHue(num hue) {
    assert(hue >= 0 && hue <= 360);
    final hslColor = toHslColor();
    return hslColor.withHue((hslColor.hue + hue) % 360).toXyzColor();
  }

  /// Returns this [XyzColor] modified with the provided [x] value.
  ///
  /// __NOTICE:__ [withX] has been deprecated, use [copyWith] instead.
  @deprecated
  XyzColor withX(num x) {
    assert(x >= 0);
    return XyzColor(x, y, z, alpha);
  }

  /// Returns this [XyzColor] modified with the provided [y] value.
  ///
  /// __NOTICE:__ [withY] has been deprecated, use [copyWith] instead.
  @deprecated
  XyzColor withY(num y) {
    assert(y >= 0);
    return XyzColor(x, y, z, alpha);
  }

  /// Returns this [XyzColor] modified with the provided [z] value.
  ///
  /// __NOTICE:__ [withZ] has been deprecated, use [copyWith] instead.
  @deprecated
  XyzColor withZ(num z) {
    assert(z >= 0);
    return XyzColor(x, y, z, alpha);
  }

  /// Returns this [XyzColor] modified with the provided [alpha] value.
  ///
  /// __NOTICE:__ [withAlpha] has been deprecated, use [copyWith] instead.
  @deprecated
  @override
  XyzColor withAlpha(int alpha) {
    assert(alpha >= 0 && alpha <= 255);
    return XyzColor(x, y, z, alpha);
  }

  @override
  XyzColor withOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return copyWith(alpha: (opacity * 255).round());
  }

  @override
  XyzColor withValues(List<num> values) {
    assert(values.length == 3 || values.length == 4);
    assert(values[0] >= 0);
    assert(values[1] >= 0);
    assert(values[2] >= 0);
    if (values.length == 4) assert(values[3] >= 0 && values[3] <= 255);
    return XyzColor.fromList(values);
  }

  @override
  XyzColor copyWith({
    num? x,
    num? y,
    num? z,
    int? alpha,
  }) {
    assert(x == null || x >= 0);
    assert(y == null || y >= 0);
    assert(z == null || z >= 0);
    assert(alpha == null || (alpha >= 0 && alpha <= 255));
    return XyzColor(
      x ?? this.x,
      y ?? this.y,
      z ?? this.z,
      alpha ?? this.alpha,
    );
  }

  @override
  LabColor toLabColor() => ColorConverter.xyzToLab(this);

  @override
  RgbColor toRgbColor() => ColorConverter.xyzToRgb(this);

  @override
  XyzColor toXyzColor() => this;

  /// Returns a fixed-length [List] containing the
  /// [x], [y], and [z] values, in that order.
  @override
  List<num> toList() => List<num>.from(<num>[x, y, z], growable: false);

  /// Returns a fixed-length [List] containing the
  /// [x], [y], [z], and [alpha] values, in that order.
  @override
  List<num> toListWithAlpha() =>
      List<num>.from(<num>[x, y, z, alpha], growable: false);

  /// Returns a fixed-length list containing the [x], [y], and
  /// [z] values factored to be on a 0 to 1 scale.
  List<double> toFactoredList() =>
      toList().map((xyzValue) => xyzValue / 100).toList(growable: false);

  /// Returns a fixed-length list containing the [x], [y], and
  /// [z] values factored to be on a 0 to 1 scale.
  List<double> toFactoredListWithAlpha() =>
      List<double>.from(<double>[x / 100, y / 100, z / 100, alpha / 255],
          growable: false);

  /// Constructs a [XyzColor] from [color].
  factory XyzColor.from(ColorModel color) => color.toXyzColor();

  /// Constructs a [XyzColor] from a list of [xyz] values.
  ///
  /// [xyz] must not be null and must have exactly `3` or `4` values.
  ///
  /// [x], [y], and [z] all must not be null and must be `>= 0`.
  ///
  /// The [alpha] value, if included, must be `>= 0 && <= 255`.
  factory XyzColor.fromList(List<num> values) {
    assert(values.length == 3 || values.length == 4);
    assert(values[0] >= 0);
    assert(values[1] >= 0);
    assert(values[2] >= 0);
    if (values.length == 4) assert(values[3] >= 0 && values[3] <= 255);
    final alpha = values.length == 4 ? values[3].round() : 255;
    return XyzColor(values[0], values[1], values[2], alpha);
  }

  /// Constructs a [XyzColor] from a RGB [hex] color.
  ///
  /// [hex] is case-insensitive and must be `3` or `6` characters
  /// in length, excluding an optional leading `#`.
  factory XyzColor.fromHex(String hex) =>
      ColorConverter.hexToRgb(hex).toXyzColor();

  /// Constructs a [XyzColor] from a list of [xyz] values on a `0` to `1` scale.
  ///
  /// [xyz] must not be null and must have exactly `3` or `4` values.
  ///
  /// Each of the values must be `>= 0` and `<= 1`.
  factory XyzColor.extrapolate(List<double> values) {
    assert(values.length == 3 || values.length == 4);
    assert(values[0] >= 0);
    assert(values[1] >= 0);
    assert(values[2] >= 0);
    if (values.length == 4) assert(values[3] >= 0 && values[3] <= 1);
    final alpha = values.length == 4 ? (values[3] * 255).round() : 255;
    return XyzColor(values[0] * 100, values[1] * 100, values[2] * 100, alpha);
  }

  /// Generates a [XyzColor] at random.
  ///
  /// [minX] and [maxX] constrain the generated [x] value.
  ///
  /// [minY] and [maxY] constrain the generated [y] value.
  ///
  /// [minZ] and [maxZ] constrain the generated [z] value.
  ///
  /// All min and max values must be `min <= max && max >= min`, must be
  /// in the range of `>= 0 && <= 100`, and must not be `null`.
  factory XyzColor.random({
    num minX = 0,
    num maxX = 100,
    num minY = 0,
    num maxY = 100,
    num minZ = 0,
    num maxZ = 100,
  }) {
    assert(minX >= 0 && minX <= maxX);
    assert(maxX >= minX && maxX <= 100);
    assert(minY >= 0 && minY <= maxY);
    assert(maxY >= minY && maxY <= 100);
    assert(minZ >= 0 && minZ <= maxZ);
    assert(maxZ >= minZ && maxZ <= 100);
    return XyzColor(
      ColorMath.random(minX, maxX),
      ColorMath.random(minY, maxY),
      ColorMath.random(minZ, maxZ),
    );
  }

  @override
  XyzColor convert(ColorModel other) => other.toXyzColor();

  @override
  String toString() => 'XyzColor($x, $y, $z, $alpha)';

  @override
  bool operator ==(Object other) =>
      other is XyzColor &&
      ColorMath.round(x) == ColorMath.round(other.x) &&
      ColorMath.round(y) == ColorMath.round(other.y) &&
      ColorMath.round(z) == ColorMath.round(other.z) &&
      alpha == other.alpha;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode ^ alpha.hashCode;
}