import '../../../docx.dart';
import '../components/containers/image/image_data.dart';

double emuToInches(int emus) {
  return emus / emuPerInch;
}

int inchesToEmu(num inches) {
  return (inches * emuPerInch).round();
}

double emuToCentimeters(int emus) {
  return emus / emuPerCm;
}

int centimetersToEmu(num centimeters) {
  return (centimeters * emuPerCm).round();
}

double emuToMillimeters(int emus) {
  return emus / emuPerMm;
}

int millimetersToEmu(num millimeters) {
  return (millimeters * emuPerMm).round();
}

double emuToPoints(int emus) {
  return emus / emuPerPt;
}

int pointsToEmu(num points) {
  return (points * emuPerPt).round();
}

int pixelsToEmu96dpi(num pixels) {
  return (pixels * emuPerInch / 96).round();
}

double emuToPixels96dpi(int emus) {
  return emus * 96 / emuPerInch;
}

int pixelsToEmu(num pixels, num dpi) {
  return (pixels * emuPerInch / dpi).round();
}

String formatEmuToInches(int emus, {int decimalPlaces = 4}) {
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

extension EMUConversions on int {
  double toInchesFromEmu() => emuToInches(this);

  double toCentimetersFromEmu() => emuToCentimeters(this);

  double toMillimetersFromEmu() => emuToMillimeters(this);

  double toPointsFromEmu() => emuToPoints(this);

  double toPixels96dpiFromEmu() => emuToPixels96dpi(this);

}

extension DoubleConversions on num {
  int toEmuFromInches() => inchesToEmu(this);

  int toEmuFromCentimeters() => centimetersToEmu(this);

  int toEmuFromMillimeters() => millimetersToEmu(this);

  int toEmuFromPoints() => pointsToEmu(this);

  int toEmuFromPixels96dpi() => pixelsToEmu96dpi(this);

  int toEmuFromUnit(Unit unit) => toEmu(this, unit);
  
  
}
