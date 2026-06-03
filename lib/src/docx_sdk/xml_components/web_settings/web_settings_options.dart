class WebSettingsOptions {
  /// Creates a new [WebSettingsOptions] instance.
  ///
  /// [allowPng]: Specifies whether PNG (Portable Network Graphics) images
  ///   should be allowed in the document when saved as HTML. Defaults to `false`.
  /// [targetScreenSize]: Specifies the target screen size for Web page output.
  ///   Common values include '800x600', '1024x768', '1152x864', '1280x1024'.
  /// [optimizeForBrowser]: Specifies whether to optimize the document for
  ///   display in a Web browser. Defaults to `false`.
  /// [relyOnVml]: Specifies whether to rely on VML (Vector Markup Language)
  ///   for rendering graphics in Web page output. Defaults to `true`.
  /// [doNotRelyOnCss]: Specifies whether to generate an HTML document that
  ///   does not rely on CSS (Cascading Style Sheets). Defaults to `false`.
  const WebSettingsOptions({
    this.allowPng = false,
    this.targetScreenSize,
    this.optimizeForBrowser = false,
    this.relyOnVml = true,
    this.doNotRelyOnCss = false,
  });

  /// Specifies whether PNG images should be allowed in the document
  /// when saved as HTML.
  ///
  /// Corresponds to `<w:allowPNG w:val="1|0"/>`. Defaults to `false`.
  final bool allowPng;

  /// Specifies the target screen size for Web page output.
  ///
  /// Corresponds to `<w:targetScreenSize w:val="..."/>`.
  /// Example values: '800x600', '1024x768'.
  final String? targetScreenSize;

  /// Specifies whether to optimize the document for display in a Web browser.
  ///
  /// Corresponds to `<w:optimizeForBrowser w:val="1|0"/>`. Defaults to `false`.
  final bool optimizeForBrowser;

  /// Specifies whether to rely on VML (Vector Markup Language) for rendering
  /// graphics in Web page output.
  ///
  /// Corresponds to `<w:relyOnVml w:val="1|0"/>`. Defaults to `true`.
  final bool relyOnVml;

  /// Specifies whether to generate an HTML document that does not rely on
  /// CSS (Cascading Style Sheets).
  ///
  /// Corresponds to `<w:doNotRelyOnCSS w:val="1|0"/>`. Defaults to `false`.
  final bool doNotRelyOnCss;
}
