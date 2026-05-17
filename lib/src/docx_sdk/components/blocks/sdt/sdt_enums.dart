/// Enum for SDT lock types to prevent editing.
///
/// Used by SDT Content Controls to specify the level of protection
/// applied to the control.
enum StdLock {
  /// The entire SDT is locked and cannot be edited or deleted.
  lock('sdtLocked'),

  /// Only the content of the SDT is locked; the control can be deleted
  /// but its content cannot be edited.
  lockContent('sdtContentLocked'),

  /// No lock is applied; the SDT can be fully edited.
  no('none');

  const StdLock(this.type);

  /// The XML attribute value for this lock type.
  final String type;
}

/// Enum for calendar types used in date SDT controls.
///
/// Specifies which calendar system to use for date picking.
enum SdtCalendar {
  /// Standard Gregorian calendar.
  gregorian('gregorian'),

  /// Gregorian calendar with Arabic numerals.
  gregorianArab('gregorianArab'),

  /// Gregorian calendar transliterated to English.
  gregorianXlitEnglish('gregorianXlitEnglish'),

  /// Gregorian calendar transliterated to French.
  gregorianXlitFrench('gregorianXlitFrench'),

  /// Islamic Hijri calendar.
  hijri('hijri'),

  /// Hebrew calendar.
  hebrew('hebrew'),

  /// Japanese calendar.
  japanese('japanese'),

  /// Taiwanese calendar.
  taiwan('taiwan'),

  /// Korean calendar.
  korean('korean'),

  /// Saka calendar (Indian).
  saka('saka');

  const SdtCalendar(this.value);

  /// The XML attribute value for this calendar type.
  final String value;
}

/// Enum for checkbox state symbols.
///
/// Defines the Unicode characters used to represent checked
/// and unchecked states in checkbox SDT controls.
enum SdtCheckboxState {
  /// Checked checkbox with X symbol (U+2612).
  checked('2612', 'MS Gothic', '\u2612'),

  /// Unchecked checkbox empty box (U+2610).
  unchecked('2610', 'MS Gothic', '\u2610'),

  /// Checked checkbox with checkmark (U+2713).
  checkmark('2713', 'Segoe UI Symbol', '\u2713'),

  /// Checked checkbox with filled box (U+2611).
  filled('2611', 'MS Gothic', '\u2611');

  const SdtCheckboxState(this.code, this.font, this.symbol);

  /// The Unicode code point as hex string (e.g., "2612").
  final String code;

  /// The font family for the symbol.
  final String font;

  /// The actual Unicode symbol character.
  final String symbol;
}
