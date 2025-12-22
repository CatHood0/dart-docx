
/// Options for configuring footnote or endnote properties (`w:footnotePr`, `w:endnotePr`).
class NotePropertiesOptions {
  /// Creates a new [NotePropertiesOptions] instance.
  ///
  /// [position]: Specifies where footnotes/endnotes are placed.
  /// [numberFormat]: Specifies the numbering format.
  /// [numberStart]: Specifies the starting number/letter.
  /// [numberRestart]: Specifies how numbering restarts.
  /// [fieldAugmentation]: Specifies whether field codes in the note reference
  ///   are augmented by additional formatting data.
  /// [layout]: Specifies the layout of footnotes (e.g., 'column', 'section').
  ///   Typically applies to footnotes, not endnotes.
  /// [additionalNoteIds]: A list of additional IDs for `<w:footnote>` or `<w:endnote>`
  ///   elements, beyond the standard '-1' and '0' for separators/continuations.
  const NotePropertiesOptions({
    required this.position,
    required this.numberFormat,
    required this.numberStart,
    required this.numberRestart,
    this.fieldAugmentation,
    this.layout, // More relevant for footnotes
    this.additionalNoteIds = const [],
  });

  /// Specifies where footnotes/endnotes are placed.
  final NotePosition position;

  /// Specifies the numbering format for footnotes/endnotes.
  final NoteNumberFormat numberFormat;

  /// Specifies the starting number or letter for footnotes/endnotes.
  final String numberStart;

  /// Specifies how numbering restarts for footnotes/endnotes.
  final NoteNumberRestart numberRestart;

  /// Specifies whether field codes in the note reference are augmented
  /// by additional formatting data.
  final bool? fieldAugmentation;

  /// Specifies the layout of footnotes.
  final NoteLayout? layout;

  /// A list of additional IDs for `<w:footnote>` or `<w:endnote>` elements.
  final List<String> additionalNoteIds;
}

/// Specifies where footnotes/endnotes are placed.
enum NotePosition {
  /// Footnotes at the bottom of the page.
  pageBottom('pageBottom'),

  /// Endnotes at the end of the document.
  docEnd('docEnd'),

  /// Footnotes beneath the text.
  beneathText('beneathText');

  const NotePosition(this.value);
  final String value;
}

/// Specifies the numbering format for footnotes/endnotes.
enum NoteNumberFormat {
  /// Decimal numbering (1, 2, 3...).
  decimal('decimal'),

  /// Lowercase Roman numerals (i, ii, iii...).
  lowerRoman('lowerRoman'),

  /// Uppercase Roman numerals (I, II, III...).
  upperRoman('upperRoman'),

  /// Lowercase letters (a, b, c...).
  lowerLetter('lowerLetter'),

  /// Uppercase letters (A, B, C...).
  upperLetter('upperLetter');

  const NoteNumberFormat(this.value);
  final String value;
}

/// Specifies how numbering restarts for footnotes/endnotes.
enum NoteNumberRestart {
  /// Continuous numbering.
  continuous('continuous'),

  /// Restart numbering at each section.
  section('section'),

  /// Restart numbering at each page.
  page('page');

  const NoteNumberRestart(this.value);
  final String value;
}

/// Specifies the layout of footnotes.
///
/// This enum is primarily relevant for footnotes, not endnotes.
enum NoteLayout {
  /// Footnotes arranged in columns.
  column('column'),

  /// Footnotes arranged by section.
  section('section');

  const NoteLayout(this.value);
  final String value;
}
