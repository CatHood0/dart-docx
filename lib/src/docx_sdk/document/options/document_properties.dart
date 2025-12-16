import '../../utils/constants.dart';
import '../document_margins.dart';
import '../editor/editor_options.dart';
import '../styles/document_styles.dart';

enum Orientation {
  portrait,
  landscape,
}

/// Represents the common properties to be filled
/// in the document. E.g: subject, owner, modified date,
/// revisions, etc
class DocumentOptions {
  DocumentOptions({
    required this.lastModifiedBy,
    required this.owner,
    required this.subject,
    required this.title,
    required this.modifiedAt,
    required this.description,
    required this.createdAt,
    required this.revisions,
    required this.editorSettings,
    required this.orientation,
    DocumentMargins? margins,
    Set<String>? supportedFileExtensions,
    List<String> keywords = const <String>[],
    DocumentStylesSheet? styles,
  })  : supportedFileExtensions =
            supportedFileExtensions ?? kDefaultAcceptedFileExtensions,
        docStyles = styles ?? DocumentStylesSheet.base(),
        standalone = 'yes',
        keywords = keywords.join(','),
        encoding = 'UTF-8' {
    final bool isPortraitOrientation = orientation == defaultOrientation;
    this.margins =
        margins ?? (isPortraitOrientation ? portraitMargins : landscapeMargins);
    availableDocumentSpace =
        editorSettings.pageSize.width - this.margins.left - this.margins.right;
  }

  factory DocumentOptions.blank({
    String? title,
    String? owner,
    DocumentStylesSheet? styles,
  }) {
    return DocumentOptions(
      lastModifiedBy: owner ?? 'Unnamed',
      owner: owner ?? '',
      subject: '',
      title: title ?? 'Unnamed',
      revisions: 1,
      modifiedAt: DateTime.now(),
      description: '',
      createdAt: DateTime.now(),
      editorSettings: EditorOptions.standard(),
      orientation: Orientation.portrait,
      keywords: const <String>[],
      styles: styles,
    );
  }

  /// name of the person
  /// that makes the last modify to the document
  final String title;
  final String description;
  final String owner;
  final String subject;
  final String lastModifiedBy;
  final String keywords;

  final String encoding;
  final Orientation orientation;

  /// [standalone] Indicates whether the document relies on external entities or not. It can have two values:
  /// * standalone="yes": The document is self-contained and does not depend on external entities (e.g., external DTDs or schemas).
  /// * standalone="no": The document may rely on external entities.
  final String standalone;
  final DateTime modifiedAt;
  final DateTime createdAt;
  final DocumentStylesSheet docStyles;
  final EditorOptions editorSettings;
  final int revisions;
  final Set<String> supportedFileExtensions;

  late final DocumentMargins margins;

  late final double availableDocumentSpace;
}
