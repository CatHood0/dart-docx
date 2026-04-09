import '../../../docx.dart';

//TODO: add listeners to events
/// Manages all hyperlink-related operations for a Docx document,
/// including discovering and creating relationships for [HyperlinkRun] components.
class HyperlinkStore {
  HyperlinkStore();

  /// Stores discovered [HyperlinkRun] components.
  final List<HyperlinkRun> _hyperlinks = <HyperlinkRun>[];

  List<HyperlinkRun> get hyperlinks => List<HyperlinkRun>.from(_hyperlinks);

  // both are closely related, so, both have a pointer
  // to get and set elements with fastly
  late DocumentRelsCounterStore docRelsStore;

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

    //TODO: use parent methods of DocumentRoot
    for (final DocxTreeNode parent in data.root.child) {
      final List<RunBase<HyperlinkTextPart>> foundHyperlinks =
          List<RunBase<HyperlinkTextPart>>.from(
        parent.visitAllElement(
              (
                DocxTreeNode el,
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
    String hyperlinkNamespace,
  ) {
    final List<RelationShip> hyperlinkRelationships = <RelationShip>[];

    for (final HyperlinkRun hyperlink in _hyperlinks) {
      final int id = docRelsStore.getNextId(hyperlink.id);
      hyperlink.rId ??= 'rId$id';
      hyperlinkRelationships.add(
        RelationShip(
          rId: hyperlink.rId!,
          //NOTE: hyperlink can be  linked
          // to a bookmark, that makes it
          // an internal target
          target: hyperlink.child.hyperlink,
          type: hyperlinkNamespace,
          mode: 'External',
        ),
      );
    }
    return hyperlinkRelationships;
  }
}
