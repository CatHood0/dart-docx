import '../../utils/constants.dart';
import 'editor_metadata.dart';
import 'page_settings.dart';

class EditorOptions {
  EditorOptions({
    required this.fontFamily,
    required this.fontSize,
    required this.headerType,
    required this.showHeader,
    required this.footerType,
    required this.showFooter,
    required this.pageSize,
    required this.language,
    required this.defaultOrderedListStyleType,
    required this.showPageNumber,
    required this.showLineNumber,
    required this.lineNumberOptions,
    required this.decodeUnicode,
    required this.complexScriptFontSize,
    required this.metadata,
  });
  factory EditorOptions.standard({
    PageSettings? size,
    EditorMetadata? metadata,
  }) {
    return EditorOptions(
      fontFamily: defaultFont,
      fontSize: defaultFontSize,
      complexScriptFontSize: defaultFontSize,
      headerType: 'default',
      metadata: metadata ?? EditorMetadata.zero(),
      showHeader: false,
      footerType: 'default',
      showFooter: false,
      pageSize: size ?? PageSettings.a4,
      language: defaultLang,
      defaultOrderedListStyleType: 'decimal',
      showPageNumber: false,
      showLineNumber: false,
      lineNumberOptions: <String, dynamic>{
        'countBy': 1,
        'start': 0,
        'restart': 'continuous',
      },
      decodeUnicode: false,
    );
  }
  String fontFamily;
  String headerType;
  String footerType;
  String language;
  String defaultOrderedListStyleType;
  bool showHeader;
  bool showFooter;
  int fontSize;
  int complexScriptFontSize;
  PageSettings pageSize;
  EditorMetadata metadata;
  bool showPageNumber;
  bool showLineNumber;

  Map<String, dynamic> lineNumberOptions;

  bool decodeUnicode;
}
