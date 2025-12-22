import '../../../docx.dart';

/// Converts inches to DXA.
int inchesToDxa(num inches) {
  return (inches * dxaPerInch).round();
}

/// Converts DXA to inches.
double dxaToInches(num dxa) {
  return dxa / dxaPerInch;
}

/// Converts centimeters to DXA.
int centimetersToDxa(num centimeters) {
  return (centimeters * dxaPerCm).round();
}

/// Converts DXA to centimeters.
double dxaToCentimeters(num dxa) {
  return dxa / dxaPerCm;
}

/// Converts millimeters to DXA.
int millimetersToDxa(num millimeters) {
  return (millimeters * dxaPerMm).round();
}

/// Converts DXA to millimeters.
double dxaToMillimeters(num dxa) {
  return dxa / dxaPerMm;
}

/// Converts points to DXA.
int pointsToDxa(num points) {
  return (points * dxaPerPt).round();
}

/// Converts DXA to points.
double dxaToPoints(num dxa) {
  return dxa / dxaPerPt;
}

/// Converts pixels (at a specified DPI) to DXA.
/// Default DPI is 96.
int pixelsToDxa(num pixels, {num dpi = 96}) {
  // pixels to inches, then inches to dxa
  return (pixels / dpi * dxaPerInch).round();
}

/// Converts DXA to pixels (at a specified DPI).
/// Default DPI is 96.
double dxaToPixels(num dxa, {num dpi = 96}) {
  // dxa to inches, then inches to pixels
  return dxa / dxaPerInch * dpi;
}

double emuToInches(num emus) {
  return emus / emuPerInch;
}

int inchesToEmu(num inches) {
  return (inches * emuPerInch).round();
}

double emuToCentimeters(num emus) {
  return emus / emuPerCm;
}

int centimetersToEmu(num centimeters) {
  return (centimeters * emuPerCm).round();
}

double emuToMillimeters(num emus) {
  return emus / emuPerMm;
}

int millimetersToEmu(num millimeters) {
  return (millimeters * emuPerMm).round();
}

double emuToPoints(num emus) {
  return emus / emuPerPt;
}

int pointsToEmu(num points) {
  return (points * emuPerPt).round();
}

int pixelsToEmu96dpi(num pixels) {
  return (pixels * emuPerInch / 96).round();
}

double emuToPixels96dpi(num emus) {
  return emus * 96 / emuPerInch;
}

int pixelsToEmu(num pixels, num dpi) {
  return (pixels * emuPerInch / dpi).round();
}

String formatEmuToInches(num emus, {int decimalPlaces = 4}) {
  final inches = emuToInches(emus);
  return inches.toStringAsFixed(decimalPlaces);
}

int toEmu(num value, Unit unit) {
  if (unit == Unit.inch) return inchesToEmu(value);
  if (unit == Unit.cm) return centimetersToEmu(value);
  if (unit == Unit.mm) return millimetersToEmu(value);
  if (unit == Unit.pt) return pointsToEmu(value);
  if (unit == Unit.pixels96) return pixelsToEmu96dpi(value);

  throw ArgumentError('Debes proporcionar al menos un valor a convertir');
}

/// Converts inches to twips.
int inchesToTwips(num inches) {
  return (inches * twipsPerInch).round();
}

/// Converts twips to inches.
double twipsToInches(num twips) {
  return twips / twipsPerInch;
}

/// Converts centimeters to twips.
int centimetersToTwips(num centimeters) {
  return (centimeters * twipsPerCm).round();
}

/// Converts twips to centimeters.
double twipsToCentimeters(num twips) {
  return twips / twipsPerCm;
}

/// Converts millimeters to twips.
int millimetersToTwips(num millimeters) {
  return (millimeters * twipsPerMm).round();
}

/// Converts twips to millimeters.
double twipsToMillimeters(num twips) {
  return twips / twipsPerMm;
}

/// Converts points to twips.
int pointsToTwips(num points) {
  return (points * twipsPerPt).round();
}

/// Converts twips to points.
double twipsToPoints(num twips) {
  return twips / twipsPerPt;
}

/// Converts pixels (at a specified DPI) to twips.
/// Default DPI is 96.
int pixelsToTwips(num pixels, {num dpi = 96}) {
  // pixels to inches, then inches to twips
  return (pixels / dpi * twipsPerInch).round();
}

/// Converts twips to pixels (at a specified DPI).
/// Default DPI is 96.
double twipsToPixels(num twips, {num dpi = 96}) {
  // twips to inches, then inches to pixels
  return twips / twipsPerInch * dpi;
}

/// Converts a [value] from a specified [Unit] to Twips.
int toTwips(num value, Unit unit) {
  if (unit == Unit.inch) return inchesToTwips(value);
  if (unit == Unit.cm) return centimetersToTwips(value);
  if (unit == Unit.mm) return millimetersToTwips(value);
  if (unit == Unit.pt) return pointsToTwips(value);
  // Assuming 96 DPI for pixel to twips conversion if not specified otherwise
  if (unit == Unit.pixels96) return pixelsToTwips(value, dpi: 96);

  throw ArgumentError(
      'The provided unit is not supported for Twips conversion.');
}

extension EMUWithPixelsConversions on int {
  double toInchesFromEmu() => emuToInches(this);

  double toCentimetersFromEmu() => emuToCentimeters(this);

  double toMillimetersFromEmu() => emuToMillimeters(this);

  double toPointsFromEmu() => emuToPoints(this);

  double toPixels96dpiFromEmu() => emuToPixels96dpi(this);

  /// Converts EMUs to Twips (approximate, as they are different base units,
  /// but useful if you need to go from one to the other indirectly via inches).
  int toTwipsFromEmu() => inchesToTwips(emuToInches(this));
}

extension TwipsConversions on int {
  /// Converts Twips to Inches.
  double toInchesFromTwips() => twipsToInches(this);

  /// Converts Twips to Centimeters.
  double toCentimetersFromTwips() => twipsToCentimeters(this);

  /// Converts Twips to Millimeters.
  double toMillimetersFromTwips() => twipsToMillimeters(this);

  /// Converts Twips to Points.
  double toPointsFromTwips() => twipsToPoints(this);

  /// Converts Twips to Pixels (assuming 96 DPI).
  double toPixels96dpiFromTwips() => twipsToPixels(this, dpi: 96);

  /// Converts Twips to EMUs (approximate, as they are different base units,
  /// but useful if you need to go from one to the other indirectly via inches).
  int toEmuFromTwips() => inchesToEmu(twipsToInches(this));
}

extension Conversions on int {
  double toInchesFromEmu() => emuToInches(this);

  double toCentimetersFromEmu() => emuToCentimeters(this);

  double toMillimetersFromEmu() => emuToMillimeters(this);

  double toPointsFromEmu() => emuToPoints(this);

  double toPixels96dpiFromEmu() => emuToPixels96dpi(this);

  int toEmuFromInches() => inchesToEmu(this);

  int toEmuFromCentimeters() => centimetersToEmu(this);

  int toEmuFromMillimeters() => millimetersToEmu(this);

  int toEmuFromPoints() => pointsToEmu(this);

  int toEmuFromPixels96dpi() => pixelsToEmu96dpi(this);

  int toEmuFromUnit(Unit unit) => toEmu(this, unit);

  // New Twips conversions for num
  /// Converts a [num] value (e.g., inches, cm, px) to Twips.
  /// Use with Unit enum (e.g., `1.0.toTwipsFromUnit(Unit.inch)`).
  int toTwipsFromUnit(Unit unit) => toTwips(this, unit);

  /// Converts inches to twips.
  int toTwipsFromInches() => inchesToTwips(this);

  /// Converts centimeters to twips.
  int toTwipsFromCentimeters() => centimetersToTwips(this);

  /// Converts millimeters to twips.
  int toTwipsFromMillimeters() => millimetersToTwips(this);

  /// Converts points to twips.
  int toTwipsFromPoints() => pointsToTwips(this);

  /// Converts pixels (at 96 DPI) to twips.
  int toTwipsFromPixels96dpi() => pixelsToTwips(this, dpi: 96);
}

extension DoubleConversions on num {
  int toEmuFromInches() => inchesToEmu(this);

  int toEmuFromCentimeters() => centimetersToEmu(this);

  int toEmuFromMillimeters() => millimetersToEmu(this);

  int toEmuFromPoints() => pointsToEmu(this);

  int toEmuFromPixels96dpi() => pixelsToEmu96dpi(this);

  int toEmuFromUnit(Unit unit) => toEmu(this, unit);

  double toInchesFromEmu() => emuToInches(this);

  double toCentimetersFromEmu() => emuToCentimeters(this);

  double toMillimetersFromEmu() => emuToMillimeters(this);

  double toPointsFromEmu() => emuToPoints(this);

  double toPixels96dpiFromEmu() => emuToPixels96dpi(this);

  /// Converts a [num] value (e.g., inches, cm, px) to Twips.
  /// Use with Unit enum (e.g., `1.0.toTwipsFromUnit(Unit.inch)`).
  int toTwipsFromUnit(Unit unit) => toTwips(this, unit);

  /// Converts inches to twips.
  int toTwipsFromInches() => inchesToTwips(this);

  /// Converts centimeters to twips.
  int toTwipsFromCentimeters() => centimetersToTwips(this);

  /// Converts millimeters to twips.
  int toTwipsFromMillimeters() => millimetersToTwips(this);

  /// Converts points to twips.
  int toTwipsFromPoints() => pointsToTwips(this);

  /// Converts pixels (at 96 DPI) to twips.
  int toTwipsFromPixels96dpi() => pixelsToTwips(this, dpi: 96);

  int toDxaFromPixels() => pixelsToDxa(this); 
}
