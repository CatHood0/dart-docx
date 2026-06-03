import '../../components/inheriteds/inherited_node.dart';
import '../../sdk.dart';
import '../glossary_store.dart';

/// Provider for accessing [GlossaryStore] from the document tree.
///
/// Use [of] to retrieve the store from any node in the tree.
///
/// ## Example
/// ```dart
/// final store = GlossaryProvider.of(myNode);
/// store.addEntry(entry);
/// ```
class GlossaryProvider extends InheritedNode {
  GlossaryProvider({
    required super.child,
    required this.store,
    super.id,
    super.parent,
  });

  final GlossaryStore store;

  /// Retrieves the [GlossaryStore] from the nearest ancestor [GlossaryProvider].
  ///
  /// Throws an exception if no provider is found in the ancestor chain.
  static GlossaryStore of(DocxNode node) {
    final GlossaryProvider? el = node.getAncestorOfExactType<GlossaryProvider>();

    if (el == null) {
      throw Exception(
        'GlossaryProvider was not found in the tree:\n${node.dumpTree()}',
      );
    }

    return el.store;
  }

  @override
  GlossaryProvider get copy => GlossaryProvider(
        id: id,
        child: child,
        store: store,
        parent: parent,
      );

  @override
  InheritedNode copyWith({
    DocxNode<dynamic>? child,
    GlossaryStore? store,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return GlossaryProvider(
      child: child ?? this.child,
      store: store ?? this.store,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }
}
