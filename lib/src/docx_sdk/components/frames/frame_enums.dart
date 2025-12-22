enum FrameWrap {
  auto('auto'),
  none('none'),
  square('square'),
  tight('tight'),
  through('through');

  const FrameWrap(this.value);
  final String value;
}

/// Defines how a text frame is anchored vertically or horizontally relative to the page.
enum FrameAnchor {
  margin('margin'),
  page('page'),
  text('text');

  const FrameAnchor(this.value);
  final String value;
}

/// Defines the horizontal alignment of a text frame relative to its anchor.
enum FrameHorizontalAlignment {
  center('center'),
  left('left'),
  right('right');

  const FrameHorizontalAlignment(this.value);
  final String value;
}

/// Defines the vertical alignment of a text frame relative to its anchor.
enum FrameVerticalAlignment {
  bottom('bottom'),
  center('center'),
  inline('inline'),
  top('top');

  const FrameVerticalAlignment(this.value);
  final String value;
}
