import '../../../../docx.dart';

class PageSettings {
  PageSettings.fromCm(double widthCm, double heightCm)
      : width = (widthCm * dxaPerCm).roundToDouble(),
        height = (heightCm * dxaPerCm).roundToDouble() {
    assert(heightCm > 0, 'El alto debe ser mayor que 0');
    assert(widthCm > 0, 'El ancho debe ser mayor que 0');
  }

  PageSettings.fromMm(double widthMm, double heightMm)
      : this.fromCm(widthMm / 10.0, heightMm / 10.0);

  PageSettings.fromInches(double widthIn, double heightIn)
      : this.fromCm(widthIn * 2.54, heightIn * 2.54);

  PageSettings.fromDxa(this.width, this.height) {
    assert(width > 0, 'El ancho en dxa debe ser mayor que 0');
    assert(height > 0, 'El alto en dxa debe ser mayor que 0');
  }

  /// The width of the page in dxa unit
  final double width;

  /// The height of the page in dxa unit
  final double height;

  static PageSettings get a4 => PageSettings.fromCm(21.0, 29.7);
  static PageSettings get letter => PageSettings.fromCm(21.59, 27.94);
  static PageSettings get legal => PageSettings.fromCm(21.59, 35.56);
  static PageSettings get a5 => PageSettings.fromCm(14.8, 21.0);
  static PageSettings get a3 => PageSettings.fromCm(29.7, 42.0);

  (double, double) get inCm => (width / dxaPerCm, height / dxaPerCm);

  (double, double) get inMm {
    final (widthCm, heightCm) = inCm;
    return (widthCm * 10, heightCm * 10);
  }

  (double, double) get inInches {
    final (widthCm, heightCm) = inCm;
    return (widthCm / 2.54, heightCm / 2.54);
  }

  PageSettings toLandscape() => PageSettings.fromDxa(height, width);

  PageSettings toPortrait() => PageSettings.fromDxa(
      width < height ? width : height, width > height ? width : height);

  @override
  String toString() {
    final (widthCm, heightCm) = inCm;
    return 'PageSettings(${widthCm.toStringAsFixed(1)}cm × ${heightCm.toStringAsFixed(1)}cm)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageSettings &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => width.hashCode ^ height.hashCode;
}
