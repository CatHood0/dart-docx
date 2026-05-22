import '../../../docx.dart';

class DocxCompilationException implements Exception {
  const DocxCompilationException({
    required this.message,
    this.documentTitle,
    this.cause,
    this.stackTrace,
    this.node,
  });

  final String message;

  final String? documentTitle;

  final Object? cause;

  final StackTrace? stackTrace;

  final DocxNode? node;

  @override
  String toString() {
    final buffer = StringBuffer('DocxCompilationException: $message');
    if (documentTitle != null) {
      buffer.write(' (document: "$documentTitle")');
    }
    if (cause != null) {
      buffer.write('\nCaused by: $cause');
    }
    if (node != null) {
      buffer.write('\nTree: ${node!.dumpTree(suffix: '<- Origin of error')}');
    }
    return buffer.toString();
  }
}
