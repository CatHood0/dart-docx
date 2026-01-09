import 'package:image_size_getter/image_size_getter.dart';

import '../../../docx.dart';

class AutoSizeNormalizer {
  /// Converts pixels to inches using page settings
  ///
  /// Like convert 1024x1024
  static NormalizedSizeResult resizeImageBySettings(
    Size size,
    PageSize pageSize,
    DocumentMargins margins,
    int? cDpi,
  ) {
    final int dpi = cDpi ?? imageDpi;
    double widthInches = size.width / dpi;
    double heightInches = size.height / dpi;

    final double aspectRatio = widthInches / heightInches;

    // 3. Too vertical or horizontal
    if (aspectRatio < 0.1 || aspectRatio > 10.0) {
      return _handleExtremeAspect(widthInches, heightInches, pageSize.width);
    }

    // 0.5" margins
    final double availableWidth =
        pageSize.width - margins.left.emuToInches();
    if (widthInches > availableWidth) {
      final double scale = availableWidth / widthInches;
      widthInches = availableWidth;
      heightInches = heightInches * scale;
    }

    // 5. limit image height to the 80% of the page
    final double maxHeight = pageSize.height * 0.8;
    if (heightInches > maxHeight) {
      final double scale = maxHeight / heightInches;
      heightInches = maxHeight;
      widthInches = widthInches * scale;
    }

    return NormalizedSizeResult(
      width: widthInches,
      height: heightInches,
      error: null,
    );
  }

  static NormalizedSizeResult _handleExtremeAspect(
    double widthInches,
    double heightInches,
    double pageWidthInches,
  ) {
    // For vertical images
    // We try to limit them adjusting the width

    final double maxHeight = pageWidthInches * 2;
    if (heightInches > maxHeight) {
      final double scale = maxHeight / heightInches;
      heightInches = maxHeight;
      widthInches = widthInches * scale;
    }

    // minimun reasonable width
    if (widthInches < 0.5) {
      widthInches = 0.5;
    }

    return NormalizedSizeResult(
      width: widthInches,
      height: heightInches,
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

  final double? width;
  final double? height;
  final Object? error;
}
