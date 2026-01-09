import '../../../../docx.dart';

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
    required this.language,
    required this.defaultOrderedListStyleType,
    required this.showPageNumber,
    required this.showLineNumber,
    required this.decodeUnicode,
    required this.complexScriptFontSize,
    required this.metadata,
  });

  factory EditorOptions.standard({
    PageSize? size,
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
      language: language ?? DocxLanguage(
        language: LanguageCodes.englishUS,
        eastAsia: LanguageCodes.chineseCN,
        bidi: LanguageCodes.arabicSA,
      ),
      defaultOrderedListStyleType: LevelFormat.decimal.name,
      showPageNumber: false,
      showLineNumber: false,
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
  EditorMetadata metadata;
  bool showPageNumber;
  bool showLineNumber;

  bool decodeUnicode;
}
