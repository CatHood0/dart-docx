/// Represents document statistics and metadata about content composition.
///
/// This class encapsulates various quantitative metrics about a document's
/// content, typically used for displaying document statistics like word count,
/// character count, page count, etc. These values are commonly shown in
/// document editors and properties dialogs.
///
/// Example usage:
/// ```dart
/// // Create metadata from document analysis
/// final metadata = EditorMetadata(
///   paragraphs: 12,
///   lines: 45,
///   characters: 2560,
///   charactersWithSpaces: 2780,
///   words: 420,
///   pages: 3,
/// );
///
/// // Initialize with zero values
/// final emptyMetadata = EditorMetadata.zero();
/// ```
class EditorMetadata {
  /// Creates an [EditorMetadata] instance with specific document statistics.
  ///
  /// Parameters:
  /// - [paragraphs]: Number of paragraphs in the document.
  /// - [lines]: Number of lines in the document.
  /// - [characters]: Number of characters (excluding spaces).
  /// - [charactersWithSpaces]: Number of characters (including spaces).
  /// - [words]: Number of words in the document.
  /// - [pages]: Number of pages in the document.
  EditorMetadata({
    required this.paragraphs,
    required this.lines,
    required this.characters,
    required this.charactersWithSpaces,
    required this.words,
    required this.pages,
    required this.wordVersion,
    required this.docSecurity,
    required this.linksUpToDate,
    required this.hyperlinksChanged,
    this.application = kDefaultAppName,
  })  : assert(pages > 0, 'pages cannot be less or equals than zero');

  /// Creates an [EditorMetadata] instance with all values set to zero.
  ///
  /// Useful as a default or initial state before document analysis.
  EditorMetadata.zero()
      : paragraphs = 0,
        wordVersion = '',
        docSecurity = 1,
        application = kDefaultAppName,
        lines = 0,
        characters = 0,
        charactersWithSpaces = 0,
        linksUpToDate = false,
        hyperlinksChanged = false,
        words = 0,
        pages = 1;

  static const String kDefaultAppName = 'Microsoft Office Word';

  final String wordVersion;

  final String application;

  /// Number of paragraphs in the document.
  ///
  /// A paragraph is typically defined as text ending with a paragraph break.
  final int paragraphs;

  /// Number of lines in the document.
  ///
  /// Lines are determined by text wrapping within paragraphs and explicit line breaks.
  final int lines;

  /// Number of characters in the document, excluding whitespace.
  ///
  /// This count typically excludes spaces, tabs, and other whitespace characters.
  final int characters;

  /// Number of characters in the document, including spaces.
  ///
  /// This count includes all characters including spaces, tabs, and other whitespace.
  final int charactersWithSpaces;

  final int docSecurity;
  final bool linksUpToDate;
  final bool hyperlinksChanged;

  /// Number of words in the document.
  ///
  /// Word count is typically determined by splitting text on whitespace boundaries.
  final int words;

  /// Number of pages in the document.
  ///
  /// Page count depends on content length, page size, margins, and formatting.
  final int pages;
}
