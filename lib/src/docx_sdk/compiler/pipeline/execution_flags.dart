/// Flags that control which stages execute in the pipeline.
///
/// These flags allow disabling specific stages without removing
/// them from the pipeline. They are configured before compilation
/// and can be passed directly to the [compile] method or via
/// [DocxPipeline.withFlags].
///
/// Usage example:
/// ```dart
/// final archive = await pipeline.compile(document, flags: ExecutionFlags(
///   skipMediaDiscovery: true,
///   skipFontEmbedding: true,
/// ));
/// ```
///
/// See also: [DocxPipeline.withFlags] for temporary flag configuration.
class ExecutionFlags {
  const ExecutionFlags({
    this.skipMediaDiscovery = false,
    this.skipMediaSave = false,
    this.skipImageRegistration = false,
    this.skipNumberingProcessing = false,
    this.skipNumberingDiscovery = false,
    this.skipNumberingBuild = false,
    this.skipNumberingRegistration = false,
    this.skipHyperlinkDiscovery = false,
    this.skipHyperlinkRegistration = false,
    this.skipFontDiscovery = false,
    this.skipFontEmbedding = false,
    this.skipFontTable = false,
    this.skipFontRels = false,
    this.skipFontProcessing = false,
    this.skipStyleValidation = true,
    this.skipTheme = false,
    this.skipSdtDiscovery = false,
    this.skipColumnDiscovery = false,
    this.skipDocumentBuild = false,
    this.skipTreeValidations = false,
    this.forceNormalStyle = true,
    this.dynamicFontSearch = true,
    this.checkStyleRefExistence = false,
    this.skipStoreReset = false,
    this.skipErrors = true,
  });

  /// Skips the media discovery phase (images).
  final bool skipErrors;

  /// Skips the media discovery phase (images).
  final bool skipMediaDiscovery;

  /// Skips the media save phase.
  final bool skipMediaSave;

  /// Skips image registration.
  final bool skipImageRegistration;

  /// Skips document build.
  final bool skipDocumentBuild;

  /// Skips complete numbering processing.
  final bool skipNumberingProcessing;

  /// Skips numbering discovery.
  final bool skipNumberingDiscovery;

  /// Skips numbering XML build.
  final bool skipNumberingBuild;

  /// Skips numbering registration.
  final bool skipNumberingRegistration;

  /// Skips hyperlink discovery.
  final bool skipHyperlinkDiscovery;

  /// Skips hyperlink registration.
  final bool skipHyperlinkRegistration;

  /// Skips font discovery.
  final bool skipFontDiscovery;

  /// Skips font embedding.
  final bool skipFontEmbedding;

  /// Skips font table build.
  final bool skipFontTable;

  /// Skips font relations build.
  final bool skipFontRels;

  /// Skips font processing.
  final bool skipFontProcessing;

  /// Skips style validation.
  final bool skipStyleValidation;

  /// Skips tree validation.
  final bool skipTreeValidations;

  /// Forces Normal style on paragraphs without style.
  final bool forceNormalStyle;

  /// Verifies existence of each Style.ref used.
  final bool checkStyleRefExistence;

  /// Skips theme application.
  final bool skipTheme;

  /// Skips SDT (Structured Document Tags) discovery.
  final bool skipSdtDiscovery;

  /// Skips column discovery.
  final bool skipColumnDiscovery;

  /// Enables dynamic font search in content.
  final bool dynamicFontSearch;

  /// Skips the reset and initializations of the stores 
  final bool skipStoreReset;

  /// Creates a copy with modifications.
  ///
  /// Useful for creating derived flags with specific changes.
  ExecutionFlags copyWith({
    bool? skipMediaDiscovery,
    bool? skipMediaSave,
    bool? skipImageRegistration,
    bool? skipNumberingProcessing,
    bool? skipNumberingDiscovery,
    bool? skipNumberingBuild,
    bool? skipNumberingRegistration,
    bool? skipHyperlinkDiscovery,
    bool? skipHyperlinkRegistration,
    bool? skipFontDiscovery,
    bool? skipFontEmbedding,
    bool? skipFontTable,
    bool? skipFontRels,
    bool? skipFontProcessing,
    bool? skipStyleValidation,
    bool? skipTheme,
    bool? skipSdtDiscovery,
    bool? skipColumnDiscovery,
    bool? skipStoreReset,
    bool? forceNormalStyle,
    bool? dynamicFontSearch,
    bool? checkStyleRefExistence,
  }) {
    return ExecutionFlags(
      skipMediaDiscovery: skipMediaDiscovery ?? this.skipMediaDiscovery,
      skipMediaSave: skipMediaSave ?? this.skipMediaSave,
      skipStoreReset: skipStoreReset ?? this.skipStoreReset,
      skipImageRegistration:
          skipImageRegistration ?? this.skipImageRegistration,
      skipNumberingProcessing:
          skipNumberingProcessing ?? this.skipNumberingProcessing,
      skipNumberingDiscovery:
          skipNumberingDiscovery ?? this.skipNumberingDiscovery,
      skipNumberingBuild: skipNumberingBuild ?? this.skipNumberingBuild,
      skipNumberingRegistration:
          skipNumberingRegistration ?? this.skipNumberingRegistration,
      skipHyperlinkDiscovery:
          skipHyperlinkDiscovery ?? this.skipHyperlinkDiscovery,
      skipHyperlinkRegistration:
          skipHyperlinkRegistration ?? this.skipHyperlinkRegistration,
      skipFontDiscovery: skipFontDiscovery ?? this.skipFontDiscovery,
      skipFontEmbedding: skipFontEmbedding ?? this.skipFontEmbedding,
      skipFontTable: skipFontTable ?? this.skipFontTable,
      skipFontRels: skipFontRels ?? this.skipFontRels,
      skipFontProcessing: skipFontProcessing ?? this.skipFontProcessing,
      skipStyleValidation: skipStyleValidation ?? this.skipStyleValidation,
      skipTheme: skipTheme ?? this.skipTheme,
      skipSdtDiscovery: skipSdtDiscovery ?? this.skipSdtDiscovery,
      skipColumnDiscovery: skipColumnDiscovery ?? this.skipColumnDiscovery,
      forceNormalStyle: forceNormalStyle ?? this.forceNormalStyle,
      dynamicFontSearch: dynamicFontSearch ?? this.dynamicFontSearch,
      checkStyleRefExistence:
          checkStyleRefExistence ?? this.checkStyleRefExistence,
    );
  }
}
