import '../../../../docx.dart';
import '../../xml_components/settings/entities/settings.dart';

/// Defines the physical layout and structure of a document section.
///
/// This class combines page size, margins, orientation, and column settings
/// to define how content is arranged on the page. It automatically calculates
/// the available document space based on page size and margins.
///
/// Example usage:
/// ```dart
/// final layout = DocumentLayout(
///   columns: ColumnOptions(equalWidth: true, count: 2),
///   size: PageSize.a4,
///   margins: DocumentMargins.fromCm(
///     top: 2.5, right: 2.5, left: 3.0, bottom: 2.5,
///     header: 1.0, footer: 1.0, gutter: 0.0,
///   ),
///   orientation: Orientation.portrait,
/// );
/// ```
class DocumentLayout {
  DocumentLayout({
    this.columns,
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

  /// Column configuration for multi-column layouts.
  final ColumnOptions? columns;

  /// Physical dimensions of the page.
  final PageSize pageSize;

  /// Page orientation (portrait or landscape).
  final Orientation orientation;

  /// Margins around the page content.
  late final DocumentMargins margins;

  /// Calculated available width for content after accounting for margins.
  late final num availableDocumentSpace;
}

/// Page orientation options.
enum Orientation {
  /// Portrait orientation (height > width).
  portrait,

  /// Landscape orientation (width > height).
  landscape,
}

/// Comprehensive document configuration and metadata container.
///
/// This class serves as the central configuration object for a DOCX document,
/// containing all properties, settings, styles, and metadata needed to
/// generate a complete document. It combines document content properties,
/// styling information, layout configuration, and technical settings.
///
/// Example usage:
/// ```dart
/// final options = DocumentOptions.standard(
///   title: 'My Document',
///   creator: 'John Doe',
///   subject: 'Documentation Example',
///   pageSize: PageSize.letter,
///   orientation: Orientation.portrait,
///   styles: myCustomStyles,
/// );
/// ```
class DocumentOptions {
  /// Creates a complete document configuration with all properties.
  ///
  /// Parameters:
  /// - [lastModifiedBy]: Name of the person who last modified the document.
  /// - [creator]: Original author/creator of the document.
  /// - [subject]: Document subject/topic.
  /// - [title]: Document title.
  /// - [modifiedAt]: Last modification timestamp.
  /// - [description]: Document description/summary.
  /// - [createdAt]: Creation timestamp.
  /// - [editorSettings]: Editor-specific configuration.
  /// - [layoutOptions]: Page layout and formatting.
  /// - [revisions]: Number of document revisions.
  /// - [fonts]: Font definitions (referenced or embedded).
  /// - [preserveWhitespacesWhenRequired]: Whether to preserve consecutive spaces.
  /// - [supportedFileExtensions]: File extensions for embedded content.
  /// - [keywords]: Document keywords for searchability.
  /// - [styles]: Document stylesheet with paragraph and character styles.
  /// - [settings]: Advanced document settings (footnotes, math, etc.).
  /// - [webSettings]: Web-specific document settings.
  /// - [numberingOptions]: List numbering/outline definitions.
  /// - [theme]: Document theme configuration.
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
    this.revisions = 1,
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

  /// Factory constructor for creating standard document configurations.
  ///
  /// Provides sensible defaults for common document creation scenarios.
  /// Most parameters are optional with reasonable defaults.
  ///
  /// Parameters:
  /// - [section]: Document layout configuration (page size, margins, etc.).
  /// - [title]: Document title (defaults to 'Unnamed').
  /// - [creator]: Document author (defaults to 'Unnamed').
  /// - [subject]: Document subject (defaults to empty).
  /// - [description]: Document description (defaults to empty).
  /// - [revisions]: Revision count (defaults to 0).
  /// - [styles]: Custom stylesheet (defaults to base styles).
  /// - [preserveWhitespacesWhenRequired]: Preserve consecutive spaces.
  /// - [orientation]: Page orientation (defaults to portrait).
  /// - [fonts]: Font definitions for the document.
  /// - [settings]: Advanced document settings.
  /// - [webSettings]: Web-specific settings.
  /// - [theme]: Document theme.
  /// - [supportedFileExtensions]: Allowed file extensions for embedded content.
  /// - [numberingOptions]: List numbering configurations.
  /// - [pageSize]: Page dimensions (defaults to A4).
  /// - [keywords]: Search keywords.
  /// - [margins]: Page margins.
  /// - [defaultOrientation]: Default page orientation.
  factory DocumentOptions.standard({
    DocumentLayout? section,
    String? title,
    String creator = 'Unnamed',
    String subject = '',
    String description = '',
    int revisions = 1,
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

  /// Current page orientation from layout options.
  Orientation get orientation => layoutOptions.orientation;

  /// Current page size from layout options.
  PageSize get pageSize => layoutOptions.pageSize;

  /// Available content width after accounting for margins.
  num get availableDocumentSpace => layoutOptions.availableDocumentSpace;

  /// Current page margins from layout options.
  DocumentMargins get margins => layoutOptions.margins;

  /// Column configuration for multi-column layouts.
  ColumnOptions? get columns => layoutOptions.columns;

  /// Font definitions used in the document (referenced or embedded).
  final Iterable<FontProperties> fonts;

  /// Document title.
  final String title;

  /// Document description or summary.
  final String description;

  /// Original author/creator of the document.
  final String creator;

  /// Document subject or topic.
  final String subject;

  /// Person who last modified the document.
  final String lastModifiedBy;

  /// Comma-separated keywords for searchability.
  final String keywords;

  /// Page layout and formatting configuration.
  final DocumentLayout layoutOptions;

  /// Whether to preserve consecutive whitespace characters in text runs.
  ///
  /// When true, adds `xml:space="preserve"` to text runs with multiple spaces.
  final bool preserveWhitespacesWhenRequired;

  /// Document encoding (typically UTF-8 for DOCX).
  final String encoding;

  /// XML standalone declaration.
  ///
  /// - `"yes"`: Document is self-contained
  /// - `"no"`: Document depends on external entities
  final String standalone;

  /// Last modification timestamp.
  final DateTime modifiedAt;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Document stylesheet containing all paragraph and character styles.
  final DocumentStylesSheet docStyles;

  /// Editor-specific configuration and preferences.
  final EditorOptions editorSettings;

  /// Number of document revisions.
  final int revisions;

  /// File extensions allowed for embedded content (images, fonts, etc.).
  final Set<String> supportedFileExtensions;

  /// Advanced document settings (footnotes, math, compatibility, etc.).
  final SettingsOptions settings;

  /// Web-specific document settings.
  final WebSettingsOptions webSettings;

  /// Document theme configuration (colors, fonts, effects).
  final ThemeOptions theme;

  /// List numbering/outline configurations.
  final List<NumberingOptions> numberingOptions;
}
