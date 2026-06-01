/// Defines the type of a glossary entry in DOCX documents.
///
/// Glossary entries (docPart) can be of different types that determine
/// how they behave when inserted into a document.
///
/// See also:
/// - [GlossaryEntry] for the complete glossary entry data structure
/// - [GlossaryBehavior] for insertion behavior options
///
/// ## Example usage:
/// ```dart
/// final entry = GlossaryEntry(
///   name: 'PlcHdr_Nombre',
///   type: GlossaryEntryType.placeholder,
///   body: [paragraph],
/// );
/// ```
enum GlossaryEntryType {
  /// Placeholder for content controls.
  ///
  /// Used for text placeholders in forms or document templates.
  /// This is the most common type for SDT placeholders.
  ///
  /// Corresponds to `bbPlcHdr` in Office Open XML.
  placeholder('bbPlcHdr'),

  /// Standard AutoText entry.
  ///
  /// Reusable text blocks that can be quickly inserted
  /// using AutoText functionality in Word.
  ///
  /// Corresponds to `bbAutoText` in Office Open XML.
  autoText('bbAutoText'),

  /// Normal building block entry.
  ///
  /// Generic building block without special behavior.
  ///
  /// Corresponds to `bbNormal` in Office Open XML.
  normal('bbNormal'),

  /// Custom AutoText entry.
  ///
  /// User-created AutoText entries with custom behavior.
  ///
  /// Corresponds to `bbCustomAutoText` in Office Open XML.
  customAutoText('bbCustomAutoText');

  const GlossaryEntryType(this.xmlValue);

  /// The XML attribute value used in `w:type w:val="..."`.
  final String xmlValue;
}

/// Defines the behavior when inserting a glossary entry.
///
/// Determines how the content is inserted into the document,
/// such as whether it creates a new page or just inserts content.
///
/// See also:
/// - [GlossaryEntry] for the complete glossary entry data structure
/// - [GlossaryEntryType] for entry type options
///
/// ## Example usage:
/// ```dart
/// final entry = GlossaryEntry(
///   name: 'Disclaimer',
///   type: GlossaryEntryType.autoText,
///   behavior: GlossaryBehavior.page,
///   body: [disclaimerParagraph],
/// );
/// ```
enum GlossaryBehavior {
  /// Insert only the content without additional formatting.
  ///
  /// The content is inserted directly at the current position.
  ///
  /// Corresponds to `p` (content) in Office Open XML.
  content('p'),

  /// Insert content on a new page.
  ///
  /// A page break is inserted before the content.
  ///
  /// Corresponds to `s` (page) in Office Open XML.
  page('s'),

  /// Insert content on the next page.
  ///
  /// A next page section break is inserted before the content.
  ///
  /// Corresponds to `n` (nextPage) in Office Open XML.
  nextPage('n'),

  /// Insert a page break followed by the content.
  ///
  /// Similar to [page] but with different section handling.
  ///
  /// Corresponds to `pg` (paragraphAndPage) in Office Open XML.
  paragraphAndPage('pg');

  const GlossaryBehavior(this.xmlValue);

  /// The XML attribute value used in `w:behavior w:val="..."`.
  final String xmlValue;
}
