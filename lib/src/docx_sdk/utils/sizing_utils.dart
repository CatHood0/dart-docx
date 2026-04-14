import '../../../docx.dart';

/// Provides a comprehensive set of unit conversion methods as extensions on [num].
/// This allows converting between various sizing units like DXA, EMU, Twips,
/// inches, centimeters, millimeters, points, and pixels.
extension SizingConversions on num {
  /// Converts inches to line spacing units.
  int inchesToLineSpacing() => (this * lineSpacingPerInch).round();

  /// Converts an alpha value (0.0 - 1.0) to maximum alpha EMU value.
  int toAlphaUnit() => (clamp(0.0, 1.0) * maxAlphaEmu).round();

  /// Converts points to half-points.
  /// 1 point = 2 half-points.
  int ptToHalfPoints() => (this * 2).round();

  /// Converts half-points to points.
  double ealfPointsToPt() => this / 2;

  // MARK: - DXA Conversions

  /// Converts inches to DXA.
  int inchesToDxa() => (this * dxaPerInch).round();

  /// Converts DXA to inches.
  double dxaToInches() => this / dxaPerInch;

  /// Converts centimeters to DXA.
  int centimetersToDxa() => (this * dxaPerCm).round();

  /// Converts DXA to centimeters.
  double dxaToCentimeters() => this / dxaPerCm;

  /// Converts millimeters to DXA.
  int millimetersToDxa() => (this * dxaPerMm).round();

  /// Converts DXA to millimeters.
  double dxaToMillimeters() => this / dxaPerMm;

  /// Converts points to DXA.
  int ptToDxa() => (this * dxaPerPt).round();

  /// Converts DXA to points.
  /// Returns an [int] representing rounded points, as per previous implementation logic.
  int dxaToPt() => (this / dxaPerPt).round();

  /// Converts pixels (at a specified DPI) to DXA.
  /// Default DPI is 96.
  int pixelsToDxa({num dpi = 96}) => (this / dpi * dxaPerInch).round();

  /// Converts DXA to pixels (at a specified DPI).
  /// Default DPI is 96.
  double dxaToPixels({num dpi = 96}) => this / dxaPerInch * dpi;

  double pixelsToInches() => this / pixelsPerInch;

  double pixelsToCm() => this / pixelsPerCm;

  double pixelsToMm() => this / pixelsPerMm;

  int pixelsToPt() => (this * ptPerPixel).round();

  double inchesToPixels() => (this * pixelsPerInch).toDouble();

  double cmToPixels() => this * pixelsPerCm;

  double mmToPixels() => this * pixelsPerMm;

  double pointsToPixels() => this / ptPerPixel;

  int inchesToPoints() => (this * ptPerInch).round();

  double cmToPoints() => this * ptPerCm;

  double mmToPoints() => this * ptPerMm;

  double pointsToInches() => this / ptPerInch;

  double pointsToCm() => this / ptPerCm;

  double pointsToMm() => this / ptPerMm;

  int pointsToTwipsFromPoints() => (this * twipsPerPt).round();

  /// Converts EMU to inches.
  double emuToInches() => this / emuPerInch;

  /// Converts inches to EMU.
  int inchesToEmu() => (this * emuPerInch).round();

  /// Converts EMU to centimeters.
  double emuToCentimeters() => this / emuPerCm;

  /// Converts centimeters to EMU.
  int centimetersToEmu() => (this * emuPerCm).round();

  /// Converts EMU to millimeters.
  double emuToMillimeters() => this / emuPerMm;

  /// Converts millimeters to EMU.
  int millimetersToEmu() => (this * emuPerMm).round();

  /// Converts EMU to points.
  double emuToPt() => this / emuPerPt;

  /// Converts points to EMU.
  int ptToEmu() => (this * emuPerPt).round();

  /// Converts pixels to EMU (at a specified DPI).
  /// Default DPI is 96.
  num pixelsToEmu({num dpi = 96}) => (this * emuPerInch / dpi).round();

  /// Converts EMU to pixels (at a specified DPI).
  /// Default DPI is 96.
  num emuToPixels({num dpi = 96}) => this * dpi / emuPerInch;

  /// Formats EMU to inches with a specified number of decimal places.
  String formatEmuToInches({int decimalPlaces = 4}) {
    final double inches = emuToInches();
    return inches.toStringAsFixed(decimalPlaces);
  }

  /// Converts a [num] value from a specified [Unit] to EMU.
  num unitToEmu(Unit unit) {
    if (unit == Unit.inch) return inchesToEmu();
    if (unit == Unit.cm) return centimetersToEmu();
    if (unit == Unit.mm) return millimetersToEmu();
    if (unit == Unit.pt) return ptToEmu();
    if (unit == Unit.pixels96) return pixelsToEmu(dpi: 96);
    if (unit == Unit.twip) return ptToTwips();
    throw ArgumentError('No supported unit of type: ${unit.name}');
  }

  /// Converts DXA to EMU via points.
  num dxaToEmu() => this * (emuPerPt / dxaPerPt);

  /// Converts inches to twips.
  int inchesToTwips() => (this * twipsPerInch).round();

  /// Converts twips to inches.
  double twipsToInches() => this / twipsPerInch;

  /// Converts centimeters to twips.
  int centimetersToTwips() => (this * twipsPerCm).round();

  /// Converts twips to centimeters.
  double twipsToCentimeters() => this / twipsPerCm;

  /// Converts millimeters to twips.
  int millimetersToTwips() => (this * twipsPerMm).round();

  /// Converts twips to millimeters.
  double twipsToMillimeters() => this / twipsPerMm;

  /// Converts points to twips.
  int ptToTwips() => (this * twipsPerPt).round();

  /// Converts points to twips.
  int ptToLineEmu() =>
      (this * lineWidthEmuPerPoint).round().clamp(0, maxLineWidth);

  /// Converts line emu to points.
  double lineEmuToPt() => this / lineWidthEmuPerPoint;

  /// Converts twips to points.
  double twipsToPt() => this / twipsPerPt;

  /// Converts pixels (at a specified DPI) to twips.
  /// Default DPI is 96.
  int pixelsToTwips({num dpi = 96}) => (this / dpi * twipsPerInch).round();

  /// Converts twips to pixels (at a specified DPI).
  /// Default DPI is 96.
  num twipsToPixels({num dpi = 96}) => this / twipsPerInch * dpi;

  /// Converts Twips to EMUs (approximate, as they are different base units,
  /// but useful if you need to go from one to the other indirectly via inches).
  int twipsToEmu() => twipsToInches().inchesToEmu();

  /// Converts a [num] value from a specified [Unit] to Twips.
  num unitToTwips(Unit unit) {
    if (unit == Unit.inch) return inchesToTwips();
    if (unit == Unit.cm) return centimetersToTwips();
    if (unit == Unit.mm) return millimetersToTwips();
    if (unit == Unit.pt) return ptToTwips();
    if (unit == Unit.pixels96) return pixelsToTwips(dpi: 96);

    throw ArgumentError(
        'The provided unit is not supported for Twips conversion.');
  }
}
