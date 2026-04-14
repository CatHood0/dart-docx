/// Unit type for table and cell width measurements in DOCX documents.
///
/// This enum defines the different measurement units that can be used
/// when specifying widths for tables and table cells. The choice of
/// unit type affects how the width value is interpreted by DOCX processors.
///
/// Example usage:
/// ```dart
/// // Fixed width in twips
/// TableWidthType.dxa
///
/// // Percentage of available space
/// TableWidthType.pct
///
/// // Automatic width based on content
/// TableWidthType.auto
///
/// // No width specification (inherit/default)
/// TableWidthType.nil
/// ```
enum TableWidthType {
  /// Width specified in twips (1/1440 of an inch).
  ///
  /// Twips are the primary measurement unit used internally by DOCX.
  /// This provides precise, fixed-width control. Common conversions:
  /// - 1440 twips = 1 inch
  /// - 720 twips = 0.5 inch
  /// - 360 twips = 0.25 inch
  ///
  /// Example: `width: 2500, widthType: TableWidthType.dxa`
  dxa('dxa'),

  /// Width specified as a percentage of available space.
  ///
  /// Percentage values range from 0-100 (or higher for overwidth).
  /// The percentage is calculated relative to the containing element
  /// (usually the page width minus margins).
  ///
  /// Example: `width: 75, widthType: TableWidthType.pct` (75% width)
  pct('pct'),

  /// Automatic width determined by content.
  ///
  /// The table or cell will expand or contract based on its content.
  /// This is useful for tables where column widths should adjust
  /// dynamically to fit the text or other elements.
  ///
  /// Take in account that `auto` will ignore the [width]
  /// if you specified it
  ///
  ///
  /// Example: `widthType: TableWidthType.auto`
  auto('auto'),

  /// No width specification (unspecified).
  ///
  /// The width is determined by the DOCX processor's default behavior
  /// or inherited from higher-level settings. This is typically used
  /// when you want to rely on default sizing behavior.
  ///
  /// Take in account that `nil` will ignore the [width]
  /// if you specified it
  ///
  /// Example: `widthType: TableWidthType.nil`
  nil('nil'),

  /// Custom type of value that will tells to the compiler and the node
  /// to compute the width based on the available space in the page
  ///
  /// Example: `widthType: TableWidthType.expand`
  expand('expand');

  const TableWidthType(this.name);

  bool get isExpand => this == TableWidthType.expand;

  bool get isNilOrAuto =>
      this == TableWidthType.nil || this == TableWidthType.auto;

  bool get needsWidth => this == TableWidthType.pct || this == TableWidthType.dxa;

  final String name;
}

/// Rule for determining table row height behavior.
///
/// This enum defines how row heights are calculated and enforced in
/// DOCX tables. Different rules provide flexibility for various layout
/// needs, from content-based heights to fixed dimensions.
///
/// Example usage:
/// ```dart
/// // Auto height based on content
/// TableHeightRule.auto
///
/// // Minimum height with content expansion
/// TableHeightRule.atLeast
///
/// // Fixed exact height regardless of content
/// TableHeightRule.exact
/// ```
enum TableHeightRule {
  /// Automatic height based on cell content.
  ///
  /// The row height adjusts dynamically to fit all content within
  /// the cells. This is the most flexible option and works well for
  /// tables with variable content lengths.
  ///
  /// This can break the content flow when you don't set an
  /// exact height. The [VerticalAlignment] won't work if the
  /// [TableRow] has not the required height to show that alignnment
  ///
  ///
  /// Example: `heightRule: TableHeightRule.auto`
  auto('auto'),

  /// At-least height specification.
  ///
  /// The row will be at least the specified height, but can expand
  /// taller if needed to accommodate content. This provides a minimum
  /// height guarantee while still allowing content-driven expansion.
  ///
  /// The [VerticalAlignment] won't work if the [TableRow] has not the
  /// required height to show that alignnment.
  ///
  /// Example: `height: 504, heightRule: TableHeightRule.atLeast`
  atLeast('atLeast'),

  /// Exact height specification.
  ///
  /// The row will be exactly the specified height, regardless of
  /// content. If content exceeds the available space, it may be
  /// clipped or overflow depending on the DOCX processor.
  ///
  /// Use this for precise layout control when row heights must be
  /// consistent regardless of content volume.
  ///
  /// Example: `height: 1008, heightRule: TableHeightRule.exact`
  exact('exact');

  const TableHeightRule(this.name);
  final String name;
}
