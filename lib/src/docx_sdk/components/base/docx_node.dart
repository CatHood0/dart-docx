import 'package:meta/meta.dart'
    show experimental, visibleForOverriding, protected, mustCallSuper;
import 'package:xml/xml.dart' show XmlNode;

import '../../../../docx.dart'
    show
        AnchorConfig,
        CompilerLogger,
        BuildNodeContext,
        DocumentRoot,
        Effect,
        Fill,
        Geometry,
        ImageData,
        LazyNode,
        Numbering,
        Paragraph,
        ShapeBorder,
        ShapeTextBox,
        Style,
        Transform2D,
        nanoid,
        DocumentOptions;
import 'empty_node.dart';

//TODO: implement child diff for nodes to allow making cache versions of parts of the tree
// to avoid compiling all the tree every time when it's not required
abstract class DocxNode<T> {
  DocxNode({
    required this.child,
    this.parent,
    String? id,
  }) : id = id ?? nanoid(7);

  bool isEmptyNode() => this is EmptyNode;

  @experimental
  @protected
  int length = 0;

  @visibleForOverriding
  void addImage(
    ImageData data, {
    required bool anchored,
    String? id,
  }) {}

  @visibleForOverriding
  void addParagraph(
    Paragraph pr, {
    int? path,
  }) {}

  @visibleForOverriding
  void insertText(
    String text, {
    int? offset,
    int? path,
    List<Object>? styles,
    bool mergeStyles = true,
  }) {}

  @visibleForOverriding
  void deleteText({
    required int start,
    required int length,
    int? path,
  }) {}

  @visibleForOverriding
  void addListItem(
    String text, {
    required Numbering numbering,
    List<Style>? styles,
    int? path,
  }) {}

  @visibleForOverriding
  void addShape({
    required AnchorConfig config,
    required int width,
    required int height,
    required Geometry<dynamic> shape,
    String name = 'shape',
    String description = 'shape desc',
    Transform2D? transform,
    bool shapeLocks = true,
    @experimental Fill<dynamic>? fill,
    @experimental ShapeBorder? border,
    @experimental Effect<dynamic>? effect,
    @experimental ShapeTextBox? textBox,
    @experimental String? shapeId,
  }) {}

  /// Remove all the elements with the [id] specified
  ///
  /// If [path] is provided, will access directly to the element
  /// and will apply the remove action there, so, ensure that
  /// the path aims to the parent that already contains the
  /// element that needs to be remove
  @visibleForOverriding
  void removeById(String id, {List<int> path = const <int>[]}) {}

  /// Adds all the elements
  ///
  /// The way them are added depends on the class
  /// implementation
  @visibleForOverriding
  void addAll(List<DocxNode> components) {}

  /// Update element
  ///
  /// The way them are updated depends on the class
  /// implementation
  ///
  /// [strict] tells to the method that we cannot updated an element
  /// that has a different [id] value, and a different type from the
  /// expected one
  @visibleForOverriding
  void updateElement(
    DocxNode component, {
    int? index,
    bool strict = true,
  }) {}

  T child;

  int index = -1;
  int depth = -1;

  /// The xml relations id of this component
  ///
  /// Tipically is modified only when this content
  /// has a relation with .rels file
  //TODO: this should be deprecated and removed
  // since we have an store exactly for this
  String? rId;

  BuildNodeContext? _context;

  BuildNodeContext get context {
    if (context == null) {
      // shows the full tree stacktrace 
      // for the exception
      throw Exception('init() must be called');
    }
    return _context!;
  }

  /// The internal random id of this component
  final String id;
  DocxNode<dynamic>? parent;
  DocxNode<T> get copy;

  DocxNode<T> copyWith({String? id, DocxNode<T>? parent});

  @mustCallSuper
  void init(BuildNodeContext context) {
    //TODO: add diff
    _context = createdInheritedContext(context);
  }

  /// Performs all the required stuff that need to be ready
  /// before the `build` pahase
  @visibleForOverriding
  @experimental
  void perfom([BuildNodeContext? context]) {}

  List<XmlNode> buildXml({required BuildNodeContext context});
  List<XmlNode> buildXmlStyle({required BuildNodeContext context}) =>
      <XmlNode>[];

  BuildNodeContext createdInheritedContext(BuildNodeContext context) {
    return BuildNodeContext.inherited(context, this);
  }

  BuildNodeContext createdContext({DocumentOptions? options}) {
    return BuildNodeContext.base(options: options, element: this);
  }

  /// Creates a lazy version of the same node, that waits for the Compilation
  /// time to build the [DocxNode] type specified
  ///
  /// Useful for when you need the context and the stores to build graphics or images
  /// manually for your unique logic at that situation and you dont want to
  /// create an specific class for that case.
  static LazyNode<C> lazyBuild<C extends DocxNode<dynamic>>(
    C Function(BuildNodeContext, String) callback, {
    DocxNode<dynamic>? parent,
    String? id,
  }) {
    return LazyNode<C>(
      child: callback,
      parent: parent,
      id: id,
    );
  }

  List<DocxNode<T>> repeat(
    int times, {
    DocxNode<T>? Function(int index, DocxNode<T> element)? overrideCopy,
  }) {
    return List<DocxNode<T>>.generate(
      times,
      (int index) =>
          overrideCopy?.call(
            index,
            this,
          ) ??
          copy,
      growable: true,
    );
  }

  R? getAncestorOfExactType<R extends DocxNode<dynamic>>() {
    DocxNode? current = parent;
    CompilerLogger.root.debug('$runtimeType:$id will try to ');
    CompilerLogger.root.debug(
      '${' ' * depth} | search ancestor '
      'of type $R',
    );
    if (current is R) {
      CompilerLogger.root.debug(
        '${' ' * depth} |_ $R found at ${current.depth}',
      );
      return current;
    }

    if (current is DocumentRoot) {
      CompilerLogger.root.debug(
        '${' ' * depth} |_ $R not found by root limitation',
      );
      return null;
    }

    int countTries = 0;
    String lastId = current!.id;
    int loopTraverse = 0;
    while (current != null) {
      if (current is R) {
        CompilerLogger.root.debug(
          '${' ' * depth} |_ $R found at ${current.depth}',
        );
        return current;
      }

      if (loopTraverse > 0 && lastId == current.id) {
        CompilerLogger.root.debug(
          '${' ' * depth} | Hit element id again. Count: $countTries -> ${countTries + 1}',
        );
        countTries++;
      } else {
        lastId = current.id;
      }

      // Since at some points we could
      // have an infinite loop
      // we made these conditions to allow
      // hitting always in nodes that are being
      // repeated every time
      if (countTries > 3) {
        CompilerLogger.root.debug(
          '${' ' * depth} |_ Hit element ${current.runtimeType} '
          'with id $id too many times. '
          'Breaking loop...',
        );
        return null;
      }
      loopTraverse++;
      current = current.parent;
    }
    CompilerLogger.root.debug('${' ' * depth} |_ $R was not found');
    return null;
  }

  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  });
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  });
}
