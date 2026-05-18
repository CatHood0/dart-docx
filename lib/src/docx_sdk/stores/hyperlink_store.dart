import '../../../docx.dart';

//TODO: add listeners to events
/// Manages all hyperlink-related operations for a Docx document,
/// including discovering and creating relationships for [HyperlinkRun] components.
class HyperlinkStore extends Store {
  HyperlinkStore();

  /// Stores discovered [HyperlinkRun] components.
  final List<HyperlinkRun> _hyperlinks = <HyperlinkRun>[];

  //TODO: use paths instead of direct instances
  List<HyperlinkRun> get hyperlinks => List<HyperlinkRun>.from(_hyperlinks);

  // both are closely related, so, both have a pointer
  // to get and set elements with fastly
  late DocumentRelsCounterStore docRelsStore;

  @override
  String get storeName => 'Hyperlink store';

  /// Resets the hyperlink store to its initial state, clearing all discovered data.
  @override
  void reset() {
    _hyperlinks.clear();
  }

  @override
  void initialize(PipelineContext context) {
    docRelsStore = context.getStoreOfExactType()!;
  }

  /// Discovers all [HyperlinkRun] elements from the provided [DocxDocument] structure
  /// and stores them internally.
  ///
  /// This method clears any previously discovered hyperlinks before starting.
  /// [data] is the [DocxDocument] to scan.
  void discoverHyperlinks(DocxDocument data) {
    _hyperlinks.clear();

    //TODO: use parent methods of DocumentRoot
    for (final DocxNode parent in data.root.child) {
      final List<HyperlinkRun> foundHyperlinks = List<HyperlinkRun>.from(
        parent.visitAllElement(
              (DocxNode el) => el is HyperlinkRun,
              visitChildrenIfNeeded: true,
            ) ??
            <HyperlinkRun>[],
      );
      _hyperlinks.addAll(foundHyperlinks);
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

    //TODO: this is difficult since it depends fully on the
    // that the instance passed it's directly shared
    for (final HyperlinkRun hyperlink in _hyperlinks) {
      final int id = docRelsStore.getNextId(hyperlink.id);
      final owner = hyperlink.parent!;
      hyperlink.rId ??= 'rId$id';
      //TODO: this is a workaround to making more strict the update
      // and avoid using direct instances
      // ignore: invalid_use_of_visible_for_overriding_member
      owner.updateElement(
        hyperlink,
        index: hyperlink.index,
      );
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
