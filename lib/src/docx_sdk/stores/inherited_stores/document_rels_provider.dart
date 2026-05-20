import '../../components/inheriteds/inherited_node.dart';
import '../../sdk.dart';

class DocumentRelsProvider extends InheritedNode {
  DocumentRelsProvider({
    required super.child,
    required this.store,
    super.id,
    super.parent,
  });

  final DocumentRelsCounterStore store;

  static DocumentRelsCounterStore of(DocxNode node) {
    final DocumentRelsProvider? el = node.getAncestorOfExactType<DocumentRelsProvider>();

    //TODO: improve error
    if (el == null) {
      throw Exception('InheritedDocumentRelsStore was not provided in the tree');
    }

    return el.store;
  }

  @override
  DocumentRelsProvider get copy => DocumentRelsProvider(
        id: id,
        child: child,
        store: store,
        parent: parent,
      );

  @override
  InheritedNode copyWith({
    DocxNode<dynamic>? child,
    DocumentRelsCounterStore? store,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return DocumentRelsProvider(
      child: child ?? this.child,
      store: store ?? this.store,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }
}
