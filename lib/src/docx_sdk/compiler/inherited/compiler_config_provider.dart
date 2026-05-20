import '../../../../docx.dart';
import '../../components/inheriteds/inherited_node.dart';

class CompilerConfigProvider extends InheritedNode {
  CompilerConfigProvider({
    required this.options,
    required this.normalStyleIfNeeded,
    required this.normalStyle,
    required super.child,
    this.noTrim = true,
    this.checkStyleRefExistence = false,
    Map<String, int>? lastNumberingIds,
    super.id,
    super.parent,
  }) {
    child
      ..parent = this
      ..index = 0;
  }

  factory CompilerConfigProvider.standard({
    required DocumentOptions? options,
    required DocxNode child,
    Map<String, int>? lastNumberingIds,
    String? id,
    DocxNode? parent,
  }) {
    return CompilerConfigProvider(
      id: id,
      noTrim: true,
      checkStyleRefExistence: false,
      normalStyleIfNeeded: true,
      normalStyle: Style.ref('Normal'),
      lastNumberingIds: lastNumberingIds,
      parent: parent,
      options: options ?? DocumentOptions.standard(title: 'unnamed'),
      child: child,
    );
  }

  static CompilerConfigProvider? of(DocxNode node) {
    return node.getAncestorOfExactType<CompilerConfigProvider>();
  }

  /// Determines if the paragraph will be created referencing the
  /// "Normal" style
  final bool normalStyleIfNeeded;

  /// Determines if the paragraph will be created referencing the
  /// "Normal" style
  final Style normalStyle;

  final DocumentOptions options;

  /// Determines if the run instances will be preserve its whitespaces
  /// since this confirm to the compiler to assign to every text
  /// object a "preserve" attribute
  final bool noTrim;

  final bool checkStyleRefExistence;

  @override
  InheritedNode get copy => throw UnimplementedError();

  @override
  InheritedNode copyWith({
    DocxNode<dynamic>? child,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    throw UnimplementedError();
  }
}
