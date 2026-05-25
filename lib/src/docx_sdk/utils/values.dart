import '../sdk.dart';

int ensureInteger(num number) {
  if (number.isNaN || number.isInfinite) {
    throw Exception('Invalid value '
        '"$number" specified. '
        'Must be an integer.');
  }
  return number.toInt();
}

abstract class UnitValue {
  const UnitValue(this.value);

  final num value;

  num? get min => null;
  num? get max => null;

  num toPt();

  num toEightOfPt() {
    return (toPt() / 8).round();
  }

  num toInches();
  num toDxa();
  num toCm();
  num toMm();
  num toPixels([num dpi = 96]);
  num toTwips([num dpi = 96]);
  num toEmu();

  num operator *(UnitValue unit) {
    return value * unit.value;
  }

  bool operator >(UnitValue unit) {
    return value > unit.value;
  }

  bool operator <(UnitValue unit) {
    return value < unit.value;
  }

  num operator %(UnitValue unit) {
    return value % unit.value;
  }

  num operator /(UnitValue unit) {
    return value / unit.value;
  }

  num operator +(UnitValue unit) {
    return value + unit.value;
  }

  num operator -(UnitValue unit) {
    return value - unit.value;
  }

  @override
  bool operator ==(Object other) {
    if (other is! UnitValue) return false;
    return runtimeType == other.runtimeType && value == other.value;
  }

  @override
  int get hashCode => Object.hash(
        runtimeType,
        value,
      );
}

class RawUnit extends UnitValue {
  RawUnit(super.value);

  @override
  num toCm() => value;

  @override
  num toDxa() => value;

  @override
  num toEmu() => value;

  @override
  num toInches() => value;

  @override
  num toMm() => value;

  @override
  num toPixels([num dpi = 96]) => value;

  @override
  num toPt() => value;

  @override
  num toTwips([num dpi = 96]) => value;
}

class Millimeter extends UnitValue {
  const Millimeter(super.value);

  @override
  num toCm() {
    return value / mmPerCm;
  }

  @override
  num toDxa() {
    return value.millimetersToDxa();
  }

  @override
  num toInches() {
    return value / mmPerInch;
  }

  @override
  num toMm() {
    return value;
  }

  @override
  num toPixels([num dpi = 96]) {
    return value.mmToPixels();
  }

  @override
  num toPt() {
    return value.mmToPoints();
  }

  @override
  num toTwips([num dpi = 96]) {
    return value.millimetersToTwips();
  }

  @override
  num toEmu() {
    return (value * emuPerMm).round();
  }
}

class Centimeter extends UnitValue {
  const Centimeter(super.value);

  @override
  num toCm() {
    return value;
  }

  @override
  num toDxa() {
    return value.centimetersToDxa();
  }

  @override
  num toInches() {
    return value / cmPerInch;
  }

  @override
  num toMm() {
    return value * mmPerCm;
  }

  @override
  num toPixels([num dpi = 96]) {
    return value.cmToPixels();
  }

  @override
  num toPt() {
    return value.cmToPoints();
  }

  @override
  num toTwips([num dpi = 96]) {
    return value.centimetersToTwips();
  }

  @override
  num toEmu() {
    return (value * emuPerCm).round();
  }
}

class Point extends UnitValue {
  const Point(super.value);

  @override
  num toCm() {
    return value * cmPerPt;
  }

  @override
  num toDxa() {
    return value.ptToDxa();
  }

  @override
  num toInches() {
    return value / ptPerInch;
  }

  @override
  num toMm() {
    return value * mmPerPt;
  }

  @override
  num toPixels([num dpi = 96]) {
    return value.pointsToPixels();
  }

  @override
  num toPt() {
    return value;
  }

  @override
  num toTwips([num dpi = 96]) {
    return value.ptToTwips();
  }

  @override
  num toEmu() {
    return (value * emuPerPt).round();
  }
}

class Twip extends UnitValue {
  const Twip(super.value);

  @override
  num toCm() {
    return value * cmPerTwip;
  }

  @override
  num toDxa() {
    return value; // 1 twip = 1 dxa
  }

  @override
  num toInches() {
    return value.twipsToInches();
  }

  @override
  num toMm() {
    return value * mmPerTwip;
  }

  @override
  num toPixels([num dpi = 96]) {
    return value.twipsToPixels(dpi: dpi);
  }

  @override
  num toPt() {
    return value.twipsToPt();
  }

  @override
  num toTwips([num dpi = 96]) {
    return value;
  }

  @override
  num toEmu() {
    return (value * emuPerTwip).round();
  }
}

class Dxa extends UnitValue {
  const Dxa(super.value);

  @override
  num toCm() {
    return value.dxaToCentimeters();
  }

  @override
  num toDxa() {
    return value;
  }

  @override
  num toInches() {
    return value.dxaToInches();
  }

  @override
  num toMm() {
    return value.dxaToMillimeters();
  }

  @override
  num toPixels([num dpi = 96]) {
    return value.dxaToPixels(dpi: dpi);
  }

  @override
  num toPt() {
    return value.dxaToPt();
  }

  @override
  num toTwips([num dpi = 96]) {
    return value; // 1 dxa = 1 twip
  }

  @override
  num toEmu() {
    return (value * emuPerTwip).round(); // 1 dxa = 635 EMU (same as twip)
  }
}

class Inch extends UnitValue {
  const Inch(super.value);

  @override
  num toCm() {
    return value * cmPerInch;
  }

  @override
  num toDxa() {
    return value.inchesToDxa();
  }

  @override
  num toInches() {
    return value;
  }

  @override
  num toMm() {
    return value * mmPerInch;
  }

  @override
  num toPixels([num dpi = 96]) {
    return value.inchesToPixels();
  }

  @override
  num toPt() {
    return value.inchesToPoints();
  }

  @override
  num toTwips([num dpi = 96]) {
    return value.inchesToTwips();
  }

  @override
  num toEmu() {
    return value.inchesToEmu();
  }
}

class SpacingInch extends UnitValue {
  const SpacingInch(super.value);

  @override
  num toCm() {
    return value * cmPerInch;
  }

  @override
  num toDxa() {
    return value.inchesToDxa();
  }

  @override
  num toInches() {
    return value;
  }

  @override
  num toMm() {
    return value * mmPerInch;
  }

  @override
  num toPixels([num dpi = 96]) {
    return value.inchesToPixels();
  }

  @override
  num toPt() {
    return value.inchesToPoints();
  }

  @override
  num toTwips([num dpi = 96]) {
    return (value * kDefaultSpacing.value).round();
  }

  @override
  num toEmu() {
    return value.inchesToEmu();
  }
}

class Pixel extends UnitValue {
  const Pixel(super.value);

  @override
  num toCm() {
    return value.pixelsToCm();
  }

  @override
  num toDxa([num dpi = 96]) {
    return value.pixelsToDxa(dpi: dpi);
  }

  @override
  num toInches() {
    return value.pixelsToInches();
  }

  @override
  num toMm() {
    return value.pixelsToMm();
  }

  @override
  num toPixels([num dpi = 96]) {
    return value;
  }

  @override
  num toPt() {
    return value.pixelsToPt();
  }

  @override
  num toTwips([num dpi = 96]) {
    return value.pixelsToTwips(dpi: dpi);
  }

  @override
  num toEmu() {
    return value.pixelsToEmu();
  }
}

class Emu extends UnitValue {
  const Emu(super.value);

  @override
  num toCm() {
    return value.emuToCentimeters();
  }

  @override
  num toDxa() {
    // 1 EMU = 1/635 DXA (because 914400 EMU/inch ÷ 1440 DXA/inch = 635)
    return (value / (emuPerInch / dxaPerInch)).round();
  }

  @override
  num toInches() {
    return value.emuToInches();
  }

  @override
  num toMm() {
    return value.emuToMillimeters();
  }

  @override
  num toPixels([num dpi = 96]) {
    return value.emuToPixels(dpi: dpi);
  }

  @override
  num toPt() {
    return value.emuToPt();
  }

  @override
  num toTwips([num dpi = 96]) {
    // 1 EMU = 1/635 twips (same as DXA relationship)
    return (value / (emuPerInch / twipsPerInch)).round();
  }

  @override
  num toEmu() {
    return value;
  }
}
