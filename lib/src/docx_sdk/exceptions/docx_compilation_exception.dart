class DocxCompilationException implements Exception {
  const DocxCompilationException({
    required this.message,
    this.documentTitle,
    this.cause,
    this.stackTrace,
  });

  /// Mensaje descriptivo del error.
  final String message;

  /// Título del documento que falló (para logging).
  final String? documentTitle;

  /// Excepción original que causó el fallo, si existe.
  final Object? cause;

  /// Stack trace original del error.
  final StackTrace? stackTrace;

  @override
  String toString() {
    final buffer = StringBuffer('DocxCompilationException: $message');
    if (documentTitle != null) {
      buffer.write(' (documento: "$documentTitle")');
    }
    if (cause != null) {
      buffer.write('\nCausa original: $cause');
    }
    return buffer.toString();
  }
}
