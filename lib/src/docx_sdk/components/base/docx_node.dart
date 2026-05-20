import 'package:meta/meta.dart'
    show experimental, visibleForOverriding, protected, mustCallSuper;
import 'package:xml/xml.dart' show XmlNode;

import '../../../../docx.dart'
    show
        AnchorConfig,
        CompilerLogger,
        DocxRoot,
        Effect,
        Fill,
        Geometry,
        ImageData,
        Numbering,
        Paragraph,
        ShapeBorder,
        ShapeTextBox,
        Style,
        Transform2D,
        nanoid;
import 'empty_node.dart';

abstract class DocxNode<T> {
  DocxNode({
    required this.child,
    DocxNode? parent,
    String? id,
  })  : id = id ?? nanoid(7),
        _parent = parent;

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
  void updateElement(
    DocxNode component, {
    int? index,
    bool strict = true,
  }) {}

  T child;

  int index = -1;
  int get depth => path.length;

  @Deprecated(
    'setting depth value is deprecated. '
    'It is not a cached value already',
  )
  set depth(int depth) {}

  /// The xml relations id of this component
  ///
  /// Tipically is modified only when this content
  /// has a relation with .rels file
  //TODO: this should be deprecated and removed
  // since we have an store exactly for this
  String? rId;

  // Not used yet
  bool dirty = false;

  /// The internal random id of this component
  final String id;
  DocxNode? _parent;

  DocxNode? get parent => _parent;

  @mustCallSuper
  set parent(DocxNode? parent) {
    _parent = parent;
    // When set to null, is more probably than this element is removed from tree
    if (parent == null) {
      markAsDirty();
      deactivate();
      return;
    }
    if (parent.mounted) {
      init();
    }
  }

  DocxNode<T> get copy;

  DocxNode<T> copyWith({String? id, DocxNode<T>? parent});

  List<int> get path {
    if (!mounted || parent == null) {
      return <int>[];
    }
    final List<int> indexes = [index];

    DocxNode? owner = parent;
    while (owner != null && owner is! DocxRoot) {
      indexes.add(owner.index);
      owner = owner.parent;
    }

    return indexes;
  }

  void didChangeConfigurations(
    DocxNode<T> prev,
    DocxNode<T> current,
  ) {}

  @mustCallSuper
  bool get mounted => parent != null;

  void markAsDirty() {
    CompilerLogger.root.config('[$runtimeType:$id]: marked as dirty');
    dirty = true;
  }

  @mustCallSuper
  void init() {
    // Does not requires
    if (mounted && !dirty) {
      CompilerLogger.root.config(
          '${' ' * (depth + 1)} [$runtimeType:$id:${path.length}]: hit diff. Avoiding re-initialization');
      return;
    }
    CompilerLogger.root.config(
        '${' ' * (depth + 1)} [$runtimeType:$id:${path.length}]: initializated correctly into ${parent?.runtimeType}:${parent?.id}');
    perform();
    visitElement((e) {
      e.init();
      return false;
    });
  }

  void deactivate() {
    CompilerLogger.root.config(
      '[$runtimeType:$id:${path.length}]: deactivated and '
      'removed of the tree',
    );
    //TODO: ensure parent remove this element
    parent = null;
    dirty = true;
  }

  /// Performs all the required stuff that need to be ready
  /// before the `build` pahase
  @visibleForOverriding
  @experimental
  void perform() {
    CompilerLogger.root.config(
      '[$runtimeType:$id:${path.length}]: '
      'executing perform',
    );
  }

  List<XmlNode> buildXml();
  List<XmlNode> buildXmlStyle() => <XmlNode>[];

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

  bool isChildOf<R extends DocxNode>() => getAncestorOfExactType<R>() != null;

  R? getAncestorOfExactType<R extends DocxNode<dynamic>>() {
    DocxNode? current = parent;
    CompilerLogger.root.debug('===$runtimeType:$id will try to ===');
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

    if (current is DocxRoot) {
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

  String dumpTree() {
    if (parent == null) {
      return '$runtimeType:$id';
    }

    final StringBuffer buffer = StringBuffer();
    final DocxNode<T> node = this;
    final List<DocxNode> ancestors = [];

    DocxNode? current = node;
    while (current != null) {
      ancestors.add(current);
      current = current.parent;
    }

    ancestors.reversed.toList().asMap().forEach((index, ancestor) {
      final isLast = index == ancestors.length - 1;
      final prefix = index == 0 ? '' : (isLast ? '└─ ' : '├─ ');
      buffer.write('$prefix${ancestor.runtimeType}:${ancestor.id}');
      if (index < ancestors.length - 1) {
        buffer
          ..write('\n')
          ..write(' ' * (index + 1));
      }
    });

    return buffer.toString();
  }
}

class DocxElements {
  DocxElements._();

  static final DocxElements instance = DocxElements._();

  Map<String, dynamic> metadata = <String, dynamic>{};

  bool get needsPreviousInitialization => metadata['ensureInitialize'] == true;

  void ensureInitialized() {
    metadata['ensureInitialize'] = true;
  }
}
