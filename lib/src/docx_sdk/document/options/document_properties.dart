import '../../../../docx.dart';
import '../../xml_components/settings/entities/settings.dart';

//TODO: add page type (:type) to allow
// configuring how sections are added and
// its behavior
class DocumentLayout {
  DocumentLayout({
    required this.columns,
    PageSize? size,
    DocumentMargins? margins,
    this.orientation = Orientation.portrait,
  }) : pageSize = size ?? PageSize.a4 {
    final bool isPortraitOrientation = orientation == defaultOrientation;
    this.margins = margins ??
        (isPortraitOrientation
            ? kDefaultPortraitMargins
            : kDefaultLandscapeMargins);
    availableDocumentSpace =
        pageSize.width - this.margins.left - this.margins.right;
  }

  final ColumnOptions? columns;
  final PageSize pageSize;
  final Orientation orientation;

  late final DocumentMargins margins;
  late final double availableDocumentSpace;
}

enum Orientation {
  portrait,
  landscape,
}

/// Represents the common properties to be filled
/// in the document. E.g: subject, owner, modified date,
/// revisions, etc
class DocumentOptions {
  DocumentOptions({
    required this.lastModifiedBy,
    required this.creator,
    required this.subject,
    required this.title,
    required this.modifiedAt,
    required this.description,
    required this.createdAt,
    required this.editorSettings,
    required this.layoutOptions,
    this.revisions = 0,
    this.fonts = const <FontProperties>[],
    this.preserveWhitespacesWhenRequired = true,
    Set<String>? supportedFileExtensions,
    List<String> keywords = const <String>[],
    DocumentStylesSheet? styles,
    SettingsOptions? settings,
    WebSettingsOptions? webSettings,
    List<NumberingOptions>? numberingOptions,
    ThemeOptions? theme,
  })  : settings = settings ?? SettingsOptions.base(),
        webSettings = webSettings ?? const WebSettingsOptions(),
        theme = theme ?? ThemeOptions.officeTheme(font: 'Arial'),
        numberingOptions = numberingOptions ?? <NumberingOptions>[],
        supportedFileExtensions =
            supportedFileExtensions ?? kDefaultAcceptedFileExtensions,
        docStyles = styles ?? DocumentStylesSheet.base(),
        standalone = 'yes',
        keywords = keywords.join(','),
        encoding = 'UTF-8';

  factory DocumentOptions.standard({
    DocumentLayout? section,
    String? title,
    String creator = 'Unnamed',
    String subject = '',
    String description = '',
    int revisions = 0,
    DocumentStylesSheet? styles,
    bool preserveWhitespacesWhenRequired = true,
    Orientation? orientation,
    Iterable<FontProperties>? fonts,
    SettingsOptions? settings,
    WebSettingsOptions? webSettings,
    ThemeOptions? theme,
    Set<String>? supportedFileExtensions,
    List<NumberingOptions>? numberingOptions,
    PageSize? pageSize,
    List<String> keywords = const <String>[],
    DocumentMargins? margins,
    Orientation defaultOrientation = Orientation.portrait,
  }) {
    return DocumentOptions(
      lastModifiedBy: creator,
      creator: creator,
      subject: subject,
      fonts: fonts ?? const <FontProperties>[],
      theme: theme,
      settings: settings,
      numberingOptions: numberingOptions,
      webSettings: webSettings,
      layoutOptions: section ??
          DocumentLayout(
            columns: ColumnOptions(equalWidth: true),
            margins: margins,
            orientation: defaultOrientation,
            size: pageSize ?? PageSize.a4,
          ),
      title: title ?? 'Unnamed',
      revisions: revisions,
      description: description,
      editorSettings: EditorOptions.standard(),
      keywords: <String>[...keywords],
      styles: styles,
      modifiedAt: DateTime.now(),
      createdAt: DateTime.now(),
      preserveWhitespacesWhenRequired: preserveWhitespacesWhenRequired,
      supportedFileExtensions: kDefaultAcceptedFileExtensions,
    );
  }

  Orientation get orientation => layoutOptions.orientation;
  PageSize get pageSize => layoutOptions.pageSize;
  double get availableDocumentSpace => layoutOptions.availableDocumentSpace;
  DocumentMargins get margins => layoutOptions.margins;
  ColumnOptions? get columns => layoutOptions.columns;

  final Iterable<FontProperties> fonts;

  /// name of the person
  /// that makes the last modify to the document
  final String title;
  final String description;
  final String creator;
  final String subject;
  final String lastModifiedBy;
  final String keywords;
  final DocumentLayout layoutOptions;

  /// Insert `xml:space="preserve"` in all `TextRun` instances
  /// that contains two or more consecutive spaces
  final bool preserveWhitespacesWhenRequired;

  final String encoding;

  /// [standalone] Indicates whether the document relies on external entities or not. It can have two values:
  /// * standalone="yes": The document is self-contained and does not depend on external entities (e.g., external DTDs or schemas).
  /// * standalone="no": The document may rely on external entities.
  final String standalone;
  final DateTime modifiedAt;
  final DateTime createdAt;
  final DocumentStylesSheet docStyles;
  final EditorOptions editorSettings;
  final int revisions;
  final Set<String> supportedFileExtensions;
  final SettingsOptions settings;
  final WebSettingsOptions webSettings;
  final ThemeOptions theme;
  final List<NumberingOptions> numberingOptions;
}
