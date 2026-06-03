class DocxPaths {
  const DocxPaths._();

  /// content types file
  static const String contentTypesPath = '[Content_Types].xml';

  /// rels file
  static const String relsFilePath = '_rels/.rels';

  /// docProps app file
  static const String appFilePath = 'docProps/app.xml';

  /// docProps core file
  static const String coreFilePath = 'docProps/core.xml';

  /// document _rels file
  static const String documentXmlRelsFilePath = 'word/_rels/document.xml.rels';

  /// document theme file
  static const String documentXmlThemeFilePath = 'word/theme/theme1.xml';

  /// document file
  static const String documentFilePath = 'word/document.xml';

  static const String glossaryFilePath = 'word/glossary/document.xml';

  /// document font table file
  static const String fontTableXmlFilePath = 'word/fontTable.xml';

  static const String fontStorageFilePath = 'word/fonts';

  /// font table relations file
  static const String fontTableXmlRelsFilePath =
      'word/_rels/fontTable.xml.rels';

  /// document numbering file
  static const String numberingXmlFilePath = 'word/numbering.xml';

  /// document settings file
  static const String settingsXmlFilePath = 'word/settings.xml';

  /// document theme file
  static const String theme1XmlFilePath = 'word/theme/theme1.xml';

  /// document theme file
  static const String themeXmlFilePath = 'word/themes.xml';

  /// document styles file
  static const String stylesXmlFilePath = 'word/styles.xml';

  /// document web settings file
  static const String webSettingsXmlFilePath = 'word/webSettings.xml';

  static List<String> get paths => List.from(
        <String>[
          contentTypesPath,
          relsFilePath,
          appFilePath,
          coreFilePath,
          documentXmlRelsFilePath,
          documentXmlThemeFilePath,
          documentFilePath,
          fontTableXmlFilePath,
          fontStorageFilePath,
          fontTableXmlRelsFilePath,
          numberingXmlFilePath,
          settingsXmlFilePath,
          theme1XmlFilePath,
          themeXmlFilePath,
          stylesXmlFilePath,
          webSettingsXmlFilePath,
        ],
      );
}
