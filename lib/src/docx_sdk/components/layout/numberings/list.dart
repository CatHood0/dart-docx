import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../../../../../docx.dart';
import '../../../../core/extensions/cast_ext.dart';

/// Represent a more easy version that manages all stuff related with the references and ids
class NumberingList extends DocxNode<List<DocxNode>> {
  NumberingList({
    required this.refKey,
    required List<DocxNode> children,
    this.noRestartCount = false,
    this.listStyle,
    super.id,
    super.parent,
  })  : inheritFromParent = false,
        assert(refKey.isNotEmpty, 'listKey must not be empty'),
        assert(
            children.every((DocxNode<dynamic> e) =>
                e is Text ||
                e is Paragraph ||
                e is NumberingList ||
                e is Builder<NumberingList> ||
                e is RunBase && e is! Run),
            'all the '
            'children for NumberingList must '
            'be Paragraph or Text objects'),
        assert(
          listStyle == null || listStyle.type == Style.listType,
          'listStyle must be of type Style.listType',
        ),
        super(child: List.from(children)) {
    int index = 0;
    for (final DocxNode<dynamic> c in child) {
      length += c.length;
      c
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  NumberingList.one({
    required this.refKey,
    required DocxNode child,
    this.noRestartCount = false,
    this.listStyle,
    super.id,
    super.parent,
  })  : inheritFromParent = false,
        assert(refKey.isNotEmpty, 'listKey must not be empty'),
        assert(
            child is Text ||
                child is Paragraph ||
                child is NumberingList ||
                child is RunBase && child is! Run,
            'all the '
            'children for NumberingList must '
            'be Paragraph or Text objects'),
        assert(
          listStyle == null || listStyle.type == Style.listType,
          'listStyle must be of type Style.listType',
        ),
        super(child: List.from(<DocxNode>[child])) {
    int index = 0;
    for (final DocxNode<dynamic> c in this.child) {
      length += c.length;
      c
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  NumberingList.inheritOne({
    required DocxNode child,
    this.noRestartCount = false,
    this.listStyle,
    super.id,
    super.parent,
  })  : refKey = '',
        inheritFromParent = true,
        assert(
            child is Text ||
                child is Paragraph ||
                child is NumberingList ||
                child is RunBase && child is! Run,
            'all the '
            'children for NumberingList must '
            'be Paragraph or Text objects'),
        assert(
          listStyle == null || listStyle.type == Style.listType,
          'listStyle must be of type Style.listType',
        ),
        super(child: List.from(<DocxNode>[child])) {
    int index = 0;
    for (final DocxNode<dynamic> c in this.child) {
      length += c.length;
      c
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  @internal
  NumberingList.raw({
    required this.refKey,
    required this.inheritFromParent,
    required List<DocxNode> children,
    this.noRestartCount = false,
    this.listStyle,
    super.id,
    super.parent,
  })  : assert(inheritFromParent || !inheritFromParent && refKey.isNotEmpty,
            'listKey must not be empty'),
        assert(
            children.every((DocxNode<dynamic> e) =>
                e is Text ||
                e is Paragraph ||
                e is NumberingList ||
                e is RunBase && e is! Run),
            'all the '
            'children for NumberingList must '
            'be Paragraph or Text objects'),
        assert(
          listStyle == null || listStyle.type == Style.listType,
          'listStyle must be of type Style.listType',
        ),
        super(child: List.from(children)) {
    int index = 0;
    for (final DocxNode<dynamic> c in child) {
      length += c.length;
      c
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  NumberingList.inherit({
    required List<DocxNode> children,
    this.noRestartCount = false,
    this.listStyle,
    super.id,
    super.parent,
  })  : refKey = '',
        inheritFromParent = true,
        assert(
            children.every((DocxNode<dynamic> e) =>
                e is Text ||
                e is Paragraph ||
                e is NumberingList ||
                e is RunBase && e is! Run),
            'all the '
            'children for NumberingList must '
            'be Paragraph or Text objects'),
        assert(
          listStyle == null || listStyle.type == Style.listType,
          'listStyle must be of type Style.listType',
        ),
        super(child: List.from(children)) {
    int index = 0;
    for (final DocxNode<dynamic> c in child) {
      length += c.length;
      c
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  /// The list style reference key
  ///
  /// Commonly references to a [NumberingOptions]
  /// provided to the document before compilation
  final String refKey;

  /// Whether this list will inherited the [refKey]
  /// from its parent [NumberingList]
  ///
  /// It will throws an [exception] if parent
  /// of type [NumberingList] is not founded
  final bool inheritFromParent;

  /// Whether this list will use the last [refId]
  /// registered for its [refKey]
  ///
  /// Default to [false] to always using a new [refId]
  /// by every new [NumberingList] instance that its
  /// not a child of another one
  final bool noRestartCount;

  final Style? listStyle;

  static final Map<String, int> _lastNumberingIds = <String, int>{};

  static final Style listStyleRef = Style.ref('ListParagraph');

  static void clearReferences() {
    _lastNumberingIds.clear();
  }

  final List<DocxNode> _temp = <DocxNode<dynamic>>[];

  @override
  void markAsDirty() {
    super.markAsDirty();
    _temp.clear();
    //TODO: we should decrease the count for the current
    // refKey of this instance
  }

  @override
  void perform() {
    String key = refKey;

    int level = 0;
    int refId = 0;

    CompilerLogger.root.debug(
      '$runtimeType:$id Start perform execution',
    );

    if (_temp.isNotEmpty) {
      CompilerLogger.root.debug(
        '$runtimeType:$id ($depth) Hit diff. '
        'Avoiding unnecessary perfom',
      );
      return;
    }

    DocxNode? ownerList = getAncestorOfExactType<NumberingList>();
    NumberingList? lastOwner = !inheritFromParent ? null : ownerList?.cast();

    while (ownerList != null) {
      ownerList = ownerList.parent;
      if (ownerList is NumberingList) {
        CompilerLogger.root.debug(
          'Increasing '
          'level ($level -> ${level + 1}) of '
          'depth for list "$id"',
        );
        lastOwner = !inheritFromParent ? null : ownerList;
        level++;
      }
    }

    if (lastOwner == null && inheritFromParent) {
      throw Exception(
        'Not found parent $runtimeType for '
        '$runtimeType:$id at $depth when '
        'was specified that will inherited key from parent. '
        'Please, ensure that you only use $runtimeType.inherit() '
        'when you know that your element is wrapped into another $runtimeType',
      );
    }

    key = inheritFromParent ? lastOwner!.refKey : refKey;
    // nested lists uses the same refId
    _lastNumberingIds[key] = inheritFromParent || noRestartCount
        ? _lastNumberingIds[key]!
        : (_lastNumberingIds[key] ?? refId) + 1;
    // Since every refId is start in a different point when the
    // key is different, then we use this to allow sharing correctly
    // the count
    //
    // Example:
    //
    // lastNumberingIds = { "unordered": 1, "ordered": 3, "bullet": 10 }
    refId = _lastNumberingIds[key]!;
    CompilerLogger.root.info(
      'Decided Key: $key'
      '${lastOwner != null ? ' (Nested - $level)' : ''} => '
      'Numbering Map: $_lastNumberingIds',
    );

    if (isChildOf<NumberingStoreProvider>()) {
      NumberingStoreProvider.of(this).registerConcreteInstance(
        key,
        refId,
        nodeId: id,
      );
    } else {
      CompilerLogger.root.warning(
        '$runtimeType:$id => Not found '
        'NumberingStoreProvider to register concrete instance '
        'of this list element',
      );
    }

    CompilerLogger.root.info('Numbering Map: $_lastNumberingIds');

    for (DocxNode<dynamic> element in child) {
      if (element is Paragraph) {
        assert(
          element.numbering == null,
          'numbering should be NULL for $element:$id at ${element.depth} when it\'s in a $runtimeType',
        );
        _temp.add(
          element.copyWith(
            parent: this,
            styles: <Style>[
              ...element.styles,
              listStyleRef,
              if (listStyle != null) listStyle!,
            ],
            numbering: Numbering(
              level: level,
              refId: refId,
              reference: key,
            ),
          ),
        );
      } else if (element is RunBase) {
        _temp.add(
          element.copyWith(id: DocxElements.instance.createId()).paragraph(
                id: element.id,
                parent: this,
                styles: <Style>[
                  listStyleRef,
                  if (listStyle != null) listStyle!,
                ],
                numbering: Numbering(
                  level: level,
                  refId: refId,
                  reference: key,
                ),
              ),
        );
      } else if (element is Text) {
        final Paragraph pr = element.toParagraph();
        _temp.add(
          pr.copyWith(
            id: element.id,
            parent: this,
            styles: <Style>[
              listStyleRef,
              if (listStyle != null) listStyle!,
            ],
            numbering: Numbering(
              level: level,
              refId: refId,
              reference: key,
            ),
          ),
        );
      } else if (element is Builder<NumberingList>) {
        _temp.add(element.build().copyWith(parent: this));
      } else if (element is NumberingList) {
        _temp.add(element.copyWith(parent: this));
      } else {
        _temp.add(element.copyWith(
          id: element.id,
          parent: this,
        ));
      }
      if (_temp.last.dirty) {
        _temp.last
          ..init()
          ..perform();
      }
    }
  }

  @override
  List<XmlNode> buildXml() {
    List<XmlNode> nodes = <XmlNode>[];
    CompilerLogger.root.debug(
      'NumberingList: _temp: $_temp, children: $child',
    );
    for (DocxNode<dynamic> e in _temp) {
      if (e is Builder) {
        nodes.addAll(e.build().buildXml());
        continue;
      }
      nodes.addAll(e.buildXml());
    }
    return nodes;
  }

  @override
  NumberingList get copy => NumberingList(
        id: id,
        parent: parent,
        refKey: refKey,
        children: child,
        noRestartCount: noRestartCount,
        listStyle: listStyle,
      ).._temp.addAll(_temp);

  @override
  NumberingList copyWith({
    List<DocxNode<dynamic>>? child,
    String? id,
    DocxNode<dynamic>? parent,
    String? refKey,
    bool? inheritFromParent,
    bool? noRestartCount,
    Style? listStyle,
  }) =>
      NumberingList.raw(
        id: id ?? this.id,
        parent: parent ?? this.parent,
        children: child ?? this.child,
        refKey: refKey ?? this.refKey,
        inheritFromParent: inheritFromParent ?? this.inheritFromParent,
        noRestartCount: noRestartCount ?? this.noRestartCount,
        listStyle: listStyle ?? this.listStyle,
      ).._temp.addAll(_temp);

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    if (shouldGetElement(this)) return this;
    final List<DocxNode<dynamic>> children =
        DocxElements.instance.initializeByCompile
            ? child
            : _temp.isEmpty
                ? child
                : _temp;
    for (final DocxNode<dynamic> element in children) {
      if (!visitChildrenIfNeeded && shouldGetElement(element)) {
        return element;
      }
      if (visitChildrenIfNeeded) {
        final DocxNode? foundedEl = element.visitElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (foundedEl != null) {
          return foundedEl;
        }
      }
    }
    return null;
  }

  @override
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return toList();
    if (child.isEmpty) return <DocxNode>[];
    final List<DocxNode<dynamic>> children =
        DocxElements.instance.initializeByCompile
            ? child
            : _temp.isEmpty
                ? child
                : _temp;
    final List<DocxNode> elements = <DocxNode>[];
    for (final DocxNode element in children) {
      if (!visitChildrenIfNeeded && shouldGetElement(element)) {
        elements.add(element);
      }
      if (visitChildrenIfNeeded) {
        final List<DocxNode>? foundedEl = element.visitAllElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (foundedEl != null) {
          elements.addAll(foundedEl);
        }
      }
    }
    return elements;
  }
}
