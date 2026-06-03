
/// Specifies the type of system color.
enum SysColorValue {
  windowText('windowText'),
  window('window');

  const SysColorValue(this.value);
  final String value;
}

/// Specifies the type of scheme color (placeholder color).
enum SchemeColorType {
  phClr('phClr');

  const SchemeColorType(this.value);
  final String value;
}

/// Specifies the dash type for a line.
enum DashType {
  solid('solid'),
  dot('dot'),
  dash('dash'),
  longDash('longDash'),
  dashDot('dashDot'),
  longDashDot('longDashDot'),
  longDashDotDot('longDashDotDot');

  const DashType(this.value);
  final String value;
}

/// Specifies the end cap style for a line.
enum LineCapType {
  round('round'),
  square('square'),
  flat('flat');

  const LineCapType(this.value);
  final String value;
}

/// Specifies the compound line type.
enum CompoundLineType {
  sng('sng'), // Single line
  dbl('dbl'), // Double line
  thickThin('thickThin'), // Thick outside, thin inside
  thinThick('thinThick'), // Thin outside, thick inside
  tri('tri'); // Triple line

  const CompoundLineType(this.value);
  final String value;
}

/// Specifies the alignment of a line.
enum LineAlignmentType {
  ctr('ctr'), // Center alignment
  in_('in'); // Inset alignment (renamed to avoid keyword conflict)

  const LineAlignmentType(this.value);
  final String value;
}

/// Specifies whether the gradient fill rotates with the shape.
enum RotWithShapeType {
  zero('0'), // Does not rotate (renamed to avoid starting with number)
  first('1'); // Rotates with shape

  const RotWithShapeType(this.value);
  final String value;
}

// Add other enums here as discovered
