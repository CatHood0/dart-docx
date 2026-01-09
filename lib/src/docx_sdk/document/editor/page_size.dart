import '../../../../docx.dart';

class PageSize {
  PageSize.raw(double widthCm, double heightCm)
      : width = widthCm,
        height = heightCm {
    assert(heightCm > 0, 'El alto debe ser mayor que 0');
    assert(widthCm > 0, 'El ancho debe ser mayor que 0');
  }
  PageSize.fromCm(double widthCm, double heightCm)
      : width = (widthCm * dxaPerCm).roundToDouble(),
        height = (heightCm * dxaPerCm).roundToDouble() {
    assert(heightCm > 0, 'El alto debe ser mayor que 0');
    assert(widthCm > 0, 'El ancho debe ser mayor que 0');
  }

  PageSize.fromMm(double widthMm, double heightMm)
      : this.fromCm(widthMm / 10.0, heightMm / 10.0);

  PageSize.fromInches(double widthIn, double heightIn)
      : this.fromCm(widthIn * 2.54, heightIn * 2.54);

  PageSize.fromDxa(this.width, this.height) {
    assert(width > 0, 'El ancho en dxa debe ser mayor que 0');
    assert(height > 0, 'El alto en dxa debe ser mayor que 0');
  }

  /// The width of the page in dxa unit
  final double width;

  /// The height of the page in dxa unit
  final double height;

  static PageSize get a4 => PageSize.fromCm(21.0, 29.7);
  static PageSize get letter => PageSize.fromCm(21.59, 27.94);
  static PageSize get legal => PageSize.fromCm(21.59, 35.56);
  static PageSize get a5 => PageSize.fromCm(14.8, 21.0);
  static PageSize get a3 => PageSize.fromCm(29.7, 42.0);

  PageSize toCm() {
    final values = inCm;
    return PageSize.raw(values.$1, values.$2);
  }

  PageSize toInches() {
    final values = inInches;
    return PageSize.raw(values.$1, values.$2);
  }

  (double, double) get inCm => (width / dxaPerCm, height / dxaPerCm);

  (double, double) get inMm {
    final (widthCm, heightCm) = inCm;
    return (widthCm * 10, heightCm * 10);
  }

  (double, double) get inInches {
    final (widthCm, heightCm) = inCm;
    return (widthCm / 2.54, heightCm / 2.54);
  }

  PageSize toLandscape() => PageSize.fromDxa(height, width);

  PageSize toPortrait() => PageSize.fromDxa(
      width < height ? width : height, width > height ? width : height);

  @override
  String toString() {
    return 'PageSettings(${width.toStringAsFixed(1)}×${height.toStringAsFixed(1)})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageSize &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => width.hashCode ^ height.hashCode;
}
