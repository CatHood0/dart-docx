import 'package:image_size_getter/image_size_getter.dart';

import '../../../docx.dart';

class AutoSizeNormalizer {
  /// Converts pixels to inches using page settings
  ///
  /// Like convert 1024x1024
  static NormalizedSizeResult resizeImageBySettings(
    Size size,
    PageSize? pageSize,
    DocumentMargins? margins,
    int? cDpi,
  ) {
    UnitValue widthInches = Pixel(size.width);
    UnitValue heightInches = Pixel(size.height);
    if (pageSize == null || margins == null) {
      return NormalizedSizeResult(
        width: widthInches.toEmu(),
        height: heightInches.toEmu(),
        error: null,
      );
    }

    final double aspectRatio = (widthInches / heightInches).roundToDouble();

    // 3. Too vertical or horizontal
    if (aspectRatio < 0.1 || aspectRatio > 10.0) {
      return _handleExtremeAspect(
        widthInches,
        heightInches,
        pageSize.width.value.toDouble(),
      );
    }

    // 0.5" margins
    final UnitValue availableWidth = Inch(pageSize.width.toInches() - (Inch(margins.left) + Inch(margins.right)));
    if (widthInches > availableWidth) {
      final UnitValue scale = Inch(availableWidth / widthInches);
      widthInches = availableWidth;
      heightInches = Inch(heightInches * scale);
    }

    // 5. limit image height to the 80% of the page
    final UnitValue maxHeight = Inch((pageSize.height.toInches() - (Inch(margins.top)+Inch(margins.bottom))) * 0.8);
    if (heightInches > maxHeight) {
      final UnitValue scale = Inch(maxHeight / heightInches);
      heightInches = maxHeight;
      widthInches = Inch(widthInches * scale);
    }

    return NormalizedSizeResult(
      width: widthInches.toEmu(),
      height: heightInches.toEmu(),
      error: null,
    );
  }

  static NormalizedSizeResult _handleExtremeAspect(
    UnitValue width,
    UnitValue height,
    double pageWidthInches,
  ) {
    // For vertical images
    // We try to limit them adjusting the width

    final UnitValue maxHeight = Inch(pageWidthInches * 2);
    if (height > maxHeight) {
      final num scale = (maxHeight / height);
      height = maxHeight;
      width = Inch(width * Inch(scale));
    }

    // minimun reasonable width
    if (width < Inch(0.5)) {
      width = Inch(0.5);
    }

    return NormalizedSizeResult(
      width: width.toEmu(),
      height: height.toEmu(),
      error: null,
    );
  }
}

class NormalizedSizeResult {
  NormalizedSizeResult({
    this.width,
    this.height,
    this.error,
  });

  final num? width;
  final num? height;
  final Object? error;
}
