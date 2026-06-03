import '../../sdk.dart';

class PipelineConfig {
  PipelineConfig({
    this.applyCustomTheme = false,
    Style? defaultNormalStyle,
    this.normalStyleIfNeeded = true,
    this.noTrim = true,
    this.checkStyleRefExistence = false,
    this.dynamicFontSearch = true,
  }) : normalStyle = defaultNormalStyle ?? Style.ref('Normal');

  final bool applyCustomTheme;

  final Style normalStyle;

  final bool normalStyleIfNeeded;

  final bool noTrim;

  final bool checkStyleRefExistence;

  final bool dynamicFontSearch;

  PipelineConfig copyWith({
    bool? applyCustomTheme,
    Style? normalStyle,
    bool? normalStyleIfNeeded,
    bool? noTrim,
    bool? checkStyleRefExistence,
    bool? dynamicFontSearch,
  }) {
    return PipelineConfig(
      applyCustomTheme: applyCustomTheme ?? this.applyCustomTheme,
      defaultNormalStyle: normalStyle ?? this.normalStyle,
      normalStyleIfNeeded: normalStyleIfNeeded ?? this.normalStyleIfNeeded,
      noTrim: noTrim ?? this.noTrim,
      checkStyleRefExistence: checkStyleRefExistence ?? this.checkStyleRefExistence,
      dynamicFontSearch: dynamicFontSearch ?? this.dynamicFontSearch,
    );
  }
}
