import '../components/docx_document.dart';

abstract class Rule {
  /// Determines if the compiler will return an exception
  ///
  /// If true, this rule even if it returns an exception,
  /// the compiler will try to follow with the next part
  ///
  /// If false, this rule will always return the exception
  bool get ignorable => false;

  /// Validates the document with the structure, and the order that
  /// is required for Microsoft Word files
  RuleException? validate(DocxDocument document);
}

class RuleException implements Exception {
  RuleException({
    required this.reason,
    required this.node,
    required this.message,
  });

  final String reason;
  final String node;
  final String message;

  @override
  String toString() {
    return 'RuleException: found one '
        'or more issues at "$node". '
        'Reason: $reason, '
        'Details: $message';
  }
}
