/// Configuration for anchoring floating objects (images, shapes) in a DOCX document.
///
/// In DOCX, floating objects are positioned using a combination of:
/// 1. **wrapType**: How text flows around the object (square, tight, through, etc.)
/// 2. **positionH** & **positionV**: Horizontal and vertical positioning
/// 3. **anchor** relationships: What the object is anchored to (paragraph, page, etc.)
///
/// This class encapsulates the complex positioning system used by Microsoft Word.
class AnchorConfig {
  AnchorConfig({
    required this.wrapType,
    this.wrapSide,
    this.anchorLock = false,
    this.behindDoc = false,
    this.layoutInCell = false,
    this.allowOverlap = true,
    this.zOrder = 0,
    this.simplePosX = 0,
    this.simplePosY = 0,
    this.anchorOffsetX = 0,
    this.anchorOffsetY = 0,
    this.distanceFromText = const TextDistance(),
    this.horizontalAnchor = RelativeHorizontalAnchor.paragraph,
    this.verticalAnchor = RelativeVerticalAnchor.paragraph,
    this.horizontalAlign = RelativeHorizontalAlign.left,
    this.verticalAlign = RelativeVerticalAlign.top,
  }) : assert(
          () {
            // square and tight must be defined with its own
            // side configurations
            final bool isSquare = wrapType == WrapType.square;
            final bool isTight = wrapType == WrapType.tight;
            return (isSquare && isTight) ||
                (isSquare || isTight) && wrapSide != null;
          }(),
          'wrapSide must be defined when '
          'the wrapType is setted to '
          'WrapType.square or WrapType.tight',
        );

  /// Creates an inline anchor configuration (simple, in-text).
  ///
  /// For images that should behave like text characters.
  factory AnchorConfig.inline() {
    return AnchorConfig(
      wrapType: WrapType.asCharacter,
      wrapSide: WrapSide.largest,
      allowOverlap: false,
    );
  }

  /// Creates a block anchor config.
  factory AnchorConfig.block({
    bool locked = false,
  }) {
    return AnchorConfig(
      wrapType: WrapType.none,
      wrapSide: null,
      anchorLock: locked,
      allowOverlap: false,
      zOrder: 0,
    );
  }

  /// Creates a square wrap configuration with text on specified side.
  ///
  /// Most common floating image configuration.
  factory AnchorConfig.square({
    WrapSide side = WrapSide.largest,
    bool locked = false,
  }) {
    return AnchorConfig(
      wrapType: WrapType.square,
      wrapSide: side,
      anchorLock: locked,
    );
  }

  /// Creates a top-and-bottom wrap configuration.
  ///
  /// Text appears only above and below, not on sides.
  factory AnchorConfig.topAndBottom({bool locked = false}) {
    return AnchorConfig(
      wrapType: WrapType.topAndBottom,
      wrapSide: WrapSide.largest,
      anchorLock: locked,
    );
  }

  /// Creates a watermark configuration (behind document).
  factory AnchorConfig.watermark() {
    return AnchorConfig(
      wrapType: WrapType.none,
      wrapSide: WrapSide.largest,
      behindDoc: true,
      zOrder: -1,
    );
  }

  /// Creates a callout/annotation configuration (in front of text).
  factory AnchorConfig.callout() {
    return AnchorConfig(
      wrapType: WrapType.none,
      wrapSide: WrapSide.largest,
      zOrder: 9999,
    );
  }

  /// Type of text wrapping around the floating object.
  ///
  /// Corresponds to the `<wp:wrap>` element in DOCX XML.
  /// Determines the basic interaction between object and text.
  final WrapType wrapType;

  /// Which side(s) text wraps on for square/tight wrapping.
  ///
  /// Only applicable when [wrapType] is square or tight.
  /// Determines text flow direction around the object.
  final WrapSide? wrapSide;

  /// Whether the anchor is locked to its current position.
  ///
  /// When true (lock="true"), the object stays at fixed coordinates.
  /// When false, object moves with its anchor paragraph when text is added/removed.
  final bool anchorLock;

  final int simplePosX;
  final int simplePosY;

  /// Whether object is behind document text (watermark mode).
  ///
  /// Corresponds to `behindDoc="1"` in DOCX.
  /// When true, object appears behind all document content.
  final bool behindDoc;

  /// Whether object is positioned inside a table cell.
  ///
  /// Corresponds to `layoutInCell="1"` in DOCX.
  /// Affects positioning calculations within table contexts.
  final bool layoutInCell;

  /// Whether this object can overlap other floating objects.
  ///
  /// DOCX default is true. When false, objects will avoid overlapping.
  final bool allowOverlap;

  /// Z-order (stacking order) of the floating object.
  ///
  /// Higher values appear on top of lower values.
  /// Used when multiple floating objects occupy same space.
  final int zOrder;

  /// Distance to maintain between object and wrapping text.
  ///
  /// Controls the "standoff" space in all four directions.
  final TextDistance distanceFromText;

  final int anchorOffsetY;

  final int anchorOffsetX;

  /// What the horizontal position is relative to.
  ///
  /// Example: margin, page, column, character, etc.
  /// Corresponds to `relativeFrom` attribute in `<wp:positionH>`.
  final RelativeHorizontalAnchor horizontalAnchor;

  /// What the vertical position is relative to.
  ///
  /// Example: margin, page, paragraph, line, etc.
  /// Corresponds to `relativeFrom` attribute in `<wp:positionV>`.
  final RelativeVerticalAnchor verticalAnchor;

  /// Horizontal alignment relative to the horizontal anchor.
  ///
  /// How the object is aligned within its horizontal positioning context.
  final RelativeHorizontalAlign? horizontalAlign;

  /// Vertical alignment relative to the vertical anchor.
  ///
  /// How the object is aligned within its vertical positioning context.
  final RelativeVerticalAlign? verticalAlign;

  /// Whether this is an inline object (not floating).
  bool get isInline => wrapType == WrapType.asCharacter;

  /// Whether this is a floating object with text wrapping.
  bool get isFloating =>
      wrapType != WrapType.asCharacter && wrapType != WrapType.none;

  /// Whether text wraps through the object (behind/inFront).
  bool get isThrough => zOrder == -1 || zOrder > 0;

  AnchorConfig copyWith({
    WrapType? wrapType,
    WrapSide? wrapSide,
    bool? anchorLock,
    bool? behindDoc,
    bool? layoutInCell,
    bool? allowOverlap,
    int? zOrder,
    int? simplePosX,
    int? simplePosY,
    int? anchorOffsetX,
    int? anchorOffsetY,
    TextDistance? distanceFromText,
    RelativeHorizontalAnchor? horizontalAnchor,
    RelativeVerticalAnchor? verticalAnchor,
    RelativeHorizontalAlign? horizontalAlign,
    RelativeVerticalAlign? verticalAlign,
  }) {
    return AnchorConfig(
      wrapType: wrapType ?? this.wrapType,
      wrapSide: wrapSide ?? this.wrapSide,
      anchorLock: anchorLock ?? this.anchorLock,
      behindDoc: behindDoc ?? this.behindDoc,
      layoutInCell: layoutInCell ?? this.layoutInCell,
      allowOverlap: allowOverlap ?? this.allowOverlap,
      zOrder: zOrder ?? this.zOrder,
      simplePosX: simplePosX ?? this.simplePosX,
      simplePosY: simplePosY ?? this.simplePosY,
      anchorOffsetX: anchorOffsetX ?? this.anchorOffsetX,
      anchorOffsetY: anchorOffsetY ?? this.anchorOffsetY,
      distanceFromText: distanceFromText ?? this.distanceFromText,
      horizontalAnchor: horizontalAnchor ?? this.horizontalAnchor,
      verticalAnchor: verticalAnchor ?? this.verticalAnchor,
      horizontalAlign: horizontalAlign ?? this.horizontalAlign,
      verticalAlign: verticalAlign ?? this.verticalAlign,
    );
  }

  @override
  String toString() {
    return 'DocxAnchorConfig('
        'wrap: $wrapType, '
        'side: $wrapSide, '
        'locked: $anchorLock, '
        'zOrder: $zOrder, '
        'hAnchor: $horizontalAnchor, '
        'vAnchor: $verticalAnchor'
        ')';
  }
}

/// Type of text wrapping in DOCX documents.
///
/// These directly correspond to the `wrap` element's type attribute in DOCX XML.
enum WrapType {
  /// threat this element as a character
  /// so, there's no anchor customizations
  asCharacter,

  /// No text wrapping (floating, but no wrap).
  ///
  /// Object floats but text doesn't wrap around it.
  /// Text continues underneath/behind the object.
  none,

  /// Square text wrapping (rectangular boundary).
  ///
  /// Text wraps around a rectangular bounding box.
  /// Most common wrapping type for images.
  square,

  /// Tight text wrapping (follows object contours).
  ///
  /// Text wraps closely around the object's shape.
  /// Requires proper contour/polygon data.
  tight,

  /// Through wrapping (text flows through object).
  ///
  /// For objects behind or in front of text.
  /// Text appears to flow through/over the object.
  through,

  /// Text appears only above and below (not on sides).
  ///
  /// Object breaks text flow completely.
  /// Similar to "Break Text" option in Word.
  topAndBottom,
}

/// Which side text wraps on for square/tight wrapping.
///
/// Corresponds to the `wrap` element's `side` attribute in DOCX XML.
enum WrapSide {
  /// Text wraps on left side only.
  ///
  /// Object aligns to left margin/column.
  /// Text flows on right side.
  left('left'),

  /// Text wraps on right side only.
  ///
  /// Object aligns to right margin/column.
  /// Text flows on left side.
  right('right'),

  /// Text wraps on largest available side.
  ///
  /// Word automatically chooses left or right based on available space.
  /// Default and most flexible option.
  largest('largest'),

  /// Text wraps on both sides.
  ///
  /// Object is centered with text on both sides.
  /// Creates balanced magazine-style layout.
  bothSides('bothSides');

  const WrapSide(this.xmlValue);

  /// The value used in DOCX XML attributes.
  final String xmlValue;
}

/// Horizontal positioning anchor in DOCX.
///
/// What the horizontal position is relative to (`relativeFrom` attribute).
enum RelativeHorizontalAnchor {
  /// Relative to page margin.
  ///
  /// Most common for floating objects.
  margin('margin'),

  /// Relative to page edge.
  ///
  /// Ignores margins, positions from page boundary.
  page('page'),

  /// Relative to text column.
  ///
  /// Useful in multi-column layouts.
  column('column'),

  /// Relative to paragraph position.
  ///
  /// Positions relative to specific paragraph.
  paragraph('paragraph'),

  /// Relative to character position.
  ///
  /// Positions relative to specific text character.
  character('character'),

  /// Relative to left margin.
  ///
  /// Specific to left margin only.
  leftMargin('leftMargin'),

  /// Relative to right margin.
  ///
  /// Specific to right margin only.
  rightMargin('rightMargin'),

  /// Relative to inside margin (for facing pages).
  ///
  /// For book layouts with different inner/outer margins.
  insideMargin('insideMargin'),

  /// Relative to outside margin (for facing pages).
  ///
  /// For book layouts with different inner/outer margins.
  outsideMargin('outsideMargin');

  const RelativeHorizontalAnchor(this.xmlValue);

  /// The value used in DOCX XML `relativeFrom` attribute.
  final String xmlValue;
}

/// Vertical positioning anchor in DOCX.
///
/// What the vertical position is relative to (`relativeFrom` attribute).
enum RelativeVerticalAnchor {
  /// Relative to page margin.
  margin('margin'),

  /// Relative to page edge.
  page('page'),

  /// Relative to paragraph.
  ///
  /// Object moves with its anchor paragraph.
  paragraph('paragraph'),

  /// Relative to line of text.
  line('line'),

  /// Relative to top margin.
  topMargin('topMargin'),

  /// Relative to bottom margin.
  bottomMargin('bottomMargin'),

  /// Relative to inside margin (for facing pages).
  insideMargin('insideMargin'),

  /// Relative to outside margin (for facing pages).
  outsideMargin('outsideMargin');

  const RelativeVerticalAnchor(this.xmlValue);

  /// The value used in DOCX XML `relativeFrom` attribute.
  final String xmlValue;
}

/// Horizontal alignment within anchor context.
enum RelativeHorizontalAlign {
  /// Align left within anchor context.
  left('left'),

  /// Center within anchor context.
  center('center'),

  /// Align right within anchor context.
  right('right'),

  /// Align to inside (for book layouts).
  inside('inside'),

  /// Align to outside (for book layouts).
  outside('outside');

  const RelativeHorizontalAlign(this.xmlValue);

  /// The value used in DOCX XML `align` attribute.
  final String xmlValue;
}

/// Vertical alignment within anchor context.
enum RelativeVerticalAlign {
  /// Align to top of anchor context.
  top('top'),

  /// Center within anchor context.
  center('center'),

  /// Align to bottom of anchor context.
  bottom('bottom'),

  /// Align to inside (for book layouts).
  inside('inside'),

  /// Align to outside (for book layouts).
  outside('outside');

  const RelativeVerticalAlign(this.xmlValue);

  /// The value used in DOCX XML `align` attribute.
  final String xmlValue;
}

/// Distance from text in all four directions (DOCX specific).
///
/// Corresponds to the `dist` attributes in `<wp:wrap>` element.
class TextDistance {
  /// Creates text distance configuration.
  ///
  /// All values are in EMU units.
  /// Default is 0 (no extra distance).
  const TextDistance({
    this.left = 0,
    this.right = 0,
    this.top = 0,
    this.bottom = 0,
  });

  /// Creates uniform distance on all sides.
  factory TextDistance.all(int distance) {
    return TextDistance(
      left: distance,
      right: distance,
      top: distance,
      bottom: distance,
    );
  }

  /// Creates distance for left/right sides only.
  factory TextDistance.sides(int distance) {
    return TextDistance(
      left: distance,
      right: distance,
      top: 0,
      bottom: 0,
    );
  }

  /// Creates distance for top/bottom only.
  factory TextDistance.topBottom(int distance) {
    return TextDistance(
      left: 0,
      right: 0,
      top: distance,
      bottom: distance,
    );
  }

  /// Distance from left edge of object to text.
  final int left;

  /// Distance from right edge of object to text.
  final int right;

  /// Distance from top edge of object to text.
  final int top;

  /// Distance from bottom edge of object to text.
  final int bottom;

  /// Whether any distance is set (non-zero).
  bool get hasDistance => left != 0 || right != 0 || top != 0 || bottom != 0;

  TextDistance copyWith({
    int? left,
    int? right,
    int? top,
    int? bottom,
  }) {
    return TextDistance(
      left: left ?? this.left,
      right: right ?? this.right,
      top: top ?? this.top,
      bottom: bottom ?? this.bottom,
    );
  }
}
