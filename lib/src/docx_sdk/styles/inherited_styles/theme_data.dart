import '../../components/inheriteds/inherited_node.dart';
import '../../sdk.dart';

class ThemeData extends InheritedNode {
  ThemeData({
    required super.child,
    required this.styles,
    super.id,
    super.parent,
    this.heading1,
    this.heading2,
    this.heading3,
    this.heading4,
    this.heading5,
    this.heading6,
    this.list,
    this.paragraph,
    this.table,
  });

  //TODO: we need to add more defined properties to allow
  // more easy inherit from this type of node
  final DocumentStyles styles;

  TextStyle? heading1;
  TextStyle? heading2;
  TextStyle? heading3;
  TextStyle? heading4;
  TextStyle? heading5;
  TextStyle? heading6;
  TextStyle? paragraph;
  TextStyle? list;
  TextStyle? table;

  static ThemeData of(DocxNode node) {
    final ThemeData? el = node.getAncestorOfExactType<ThemeData>();

    //TODO: improve error
    if (el == null) {
      throw Exception('ThemeData was not provided in the tree');
    }

    return el;
  }

  @override
  ThemeData get copy => ThemeData(
        id: id,
        child: child,
        styles: styles,
        parent: parent,
      );

  @override
  InheritedNode copyWith({
    DocxNode<dynamic>? child,
    DocumentStyles? styles,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return ThemeData(
      child: child ?? this.child,
      styles: styles ?? this.styles,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }
}
