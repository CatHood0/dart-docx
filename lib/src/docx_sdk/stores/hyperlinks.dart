import '../../../docx.dart';

/// Manages all hyperlink-related operations for a Docx document,
/// including discovering and creating relationships for [HyperlinkRun] components.
class HyperlinkStore {
  HyperlinkStore();

  /// Stores discovered [HyperlinkRun] components.
  final List<HyperlinkRun> _hyperlinks = <HyperlinkRun>[];

  /// Resets the hyperlink store to its initial state, clearing all discovered data.
  void reset() {
    _hyperlinks.clear();
  }

  /// Discovers all [HyperlinkRun] elements from the provided [DocxDocument] structure
  /// and stores them internally.
  ///
  /// This method clears any previously discovered hyperlinks before starting.
  /// [data] is the [DocxDocument] to scan.
  void discoverHyperlinks(DocxDocument data) {
    _hyperlinks.clear(); 

    for (final ComponentContainer parent in data.sections) {
      final List<RunBase<HyperlinkTextPart>> foundHyperlinks =
          List<RunBase<HyperlinkTextPart>>.from(
        parent.visitAllElement(
              (
                DocxContent el,
              ) =>
                  el is HyperlinkRun,
              visitChildrenIfNeeded: true,
            ) ??
            <RunBase<HyperlinkTextPart>>[],
      );
      for (final RunBase<HyperlinkTextPart> hyperlink in foundHyperlinks) {
        if (hyperlink is HyperlinkRun) {
          _hyperlinks.add(hyperlink);
        }
      }
    }
  }

  /// Builds a list of [RelationShip] objects for all discovered hyperlinks.
  ///
  /// This method assigns unique relationship IDs (`rId`) to each hyperlink
  /// and creates the corresponding [RelationShip] object.
  ///
  /// [startingRId] is the base integer for relationship IDs; it will be
  /// incremented for each hyperlink.
  /// [hyperlinkNamespace] is the XML namespace URI for hyperlink relationships
  /// (e.g., `http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink`).
  ///
  /// Returns a list of [RelationShip]s for all discovered hyperlinks.
  List<RelationShip> buildHyperlinkRelationships(
    int startingRId,
    String hyperlinkNamespace,
  ) {
    int currentRId = startingRId;
    final List<RelationShip> hyperlinkRelationships = [];

    for (final HyperlinkRun hyperlink in _hyperlinks) {
      currentRId++;
      hyperlink.rId ??= 'rId$currentRId';
      hyperlinkRelationships.add(
        RelationShip(
          rId: hyperlink.rId!,
          target: hyperlink.link,
          type: hyperlinkNamespace,
          mode: 'External', // Hyperlinks are typically external
        ),
      );
    }
    return hyperlinkRelationships;
  }
}
