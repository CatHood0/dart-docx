import '../../utils/constants.dart';
import '../../utils/language_codes.dart';
import '../../xml_components/numbering/formats.dart';
import 'editor_metadata.dart';
import 'page_settings.dart';

class DocxLanguage {
  DocxLanguage({
    required this.language,
    this.eastAsia = '',
    this.bidi = '',
  });

  final String language;
  final String eastAsia;
  final String bidi;
}

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
    DocxLanguage? language,
  }) {
    return EditorOptions(
      fontFamily: defaultFont,
      fontSize: defaultFontSize,
      complexScriptFontSize: defaultFontSize,
      //TODO:  we need to work of headers and footers
      headerType: 'default',
      footerType: 'default',
      metadata: metadata ?? EditorMetadata.zero(),
      showHeader: false,
      showFooter: false,
      pageSize: size ?? PageSettings.a4,
      language: language ?? DocxLanguage(
        language: LanguageCodes.englishUS,
        eastAsia: LanguageCodes.chineseCN,
        bidi: LanguageCodes.arabicSA,
      ),
      defaultOrderedListStyleType: LevelFormat.decimal.name,
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
  DocxLanguage language;
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
