import 'dart:io';
import 'dart:typed_data';

import '../../../docx.dart';
import '../../core/extensions/cast_ext.dart';
import '../components/drawing/graphics/effects/shadow_effect.dart';

typedef MapCallback<T> = Map<String, dynamic> Function(T);
typedef FromMapCallback<T extends Object> = T Function(
    Map<String, dynamic>, Map<String, dynamic>?);

/// Global registry to get all instances to/from json objects
///
/// Commonly most of the components have its own implementation
/// for `toJson` and `fromJson` serializations through `DocxRegistry.setDefaultRegistries()`
class DocxRegistry {
  factory DocxRegistry() => _instance;

  const DocxRegistry._();

  static const DocxRegistry _instance = DocxRegistry._();

  static final Map<String, Function> toJsonRegistry = <String, Function>{};

  static final Map<String, FromMapCallback<Object>> fromJsonRegistry =
      <String, FromMapCallback<Object>>{};

  /// Transform instance `object` to its json version
  ///
  /// Before calling this method, ensure that your object
  /// have its own implementation through
  /// `DocxRegistry().setToJson(/*..*/)` method
  Map<String, dynamic>? toJson(Object object) {
    if (!hasSerialization(object)) {
      if (toJsonRegistry[object.runtimeType.toString()] == null) {
        throw Exception(
          'Not found serialization definition for '
          '"${object.runtimeType.toString()}" type',
        );
      }
    }
    final Map<String, dynamic> el =
        toJsonRegistry[object.runtimeType.toString()]!.call(object);
    el['__runtimeType__'] = object.runtimeType.toString();
    return el;
  }

  /// Transform your json instance to its `object` version
  ///
  /// Before calling this method, ensure that your object
  /// have its own implementation through
  /// `DocxRegistry().setFromJson(/*..*/)` method
  ///
  /// - [metadata]: Commonly json passed for elements that requires data
  /// that cannot be serialized to a json here, like context, configs, etc
  T? fromJson<T extends Object>(
    Map<String, dynamic> map, {
    Map<String, dynamic>? metadata,
  }) {
    if (fromJsonRegistry[T.toString()] == null &&
        map['__runtimeType__'] == null) {
      throw Exception(
        'Not found __runtimeType__ property since '
        '"${T.toString()}" is not a valid type for fromJson. '
        'Found: $map',
      );
    }
    final FromMapCallback<T>? callback =
        fromJsonRegistry[map['__runtimeType__'] as String? ?? T.toString()]
            ?.castOrNull<FromMapCallback<T>>();
    return callback?.call(map, metadata);
  }

  /// Serialize your object to a map as you want
  ///
  /// ```dart
  /// DocxRegistry().setToJson<Extent>(
  ///   (Extent node) {
  ///     return <String, dynamic>{
  ///       'cx': node.cx,
  ///       'cy': node.cy,
  ///     };
  ///   },
  /// );
  /// ```
  ///
  /// Commonly `toJson` method, inject a extra argument to json
  /// output, called `__runtimeType__` that specifies the type
  /// of the element transformed, for future deserializations
  /// that cannot be specified since its abstract implementation
  ///
  /// An example of this, is `Align` that can have any type
  /// of component as its child, so, how can the deserializer
  /// know the type? You can specify it forcely, but, you want it?
  /// to fix this, we inject that property and `fromJson` use it
  /// as a fallback to ensure that we converts the element correctly
  /// without lossing components
  bool setToJson<T extends Object>(MapCallback<T> callback) {
    toJsonRegistry[T.toString()] = callback.cast();
    return true;
  }

  /// Deserialize your json to the object as you want
  ///
  /// ```dart
  /// DocxRegistry().setFromJson<Extent>(
  ///   (Map<String, dynamic> body, metadata) {
  ///     return Extent(
  ///       cx: body['cx'],
  ///       cy: body['cy'],
  ///     );
  ///   },
  /// );
  /// ```
  bool setFromJson<T extends Object>(FromMapCallback<T> callback) {
    final FromMapCallback? prev =
        fromJsonRegistry[T.toString()]?.castOrNull<FromMapCallback>();
    if (prev != null) return false;
    fromJsonRegistry[T.toString()] = callback;
    return true;
  }

  bool hasSerialization(Object object) {
    final FromMapCallback? prev =
        fromJsonRegistry[object.runtimeType.toString()]
            ?.castOrNull<FromMapCallback>();
    final Function? el = toJsonRegistry[object.runtimeType.toString()];
    return prev != null && el != null;
  }

  static void setDefaultRegistries() {
    // Normally these elements are not used for parsing
    // but we allow transforming to avoid loss tree components
    DocxRegistry().setToJson<Builder>((Builder node) {
      final DocxNode<dynamic> element = node.build();
      return DocxRegistry().toJson(element)!;
    });

    DocxRegistry().setToJson<StatelessWidget>((StatelessWidget node) {
      final DocxNode<dynamic> element = node.build();
      return DocxRegistry().toJson(element)!;
    });
    //

    DocxRegistry().setToJson<EmptyNode>(
      (EmptyNode node) {
        return <String, dynamic>{};
      },
    );
    DocxRegistry().setFromJson<EmptyNode>(
      (Map<String, dynamic> body, metadata) {
        return EmptyNode();
      },
    );

    DocxRegistry().setToJson<Extent>(
      (Extent node) {
        return <String, dynamic>{
          'cx': node.cx,
          'cy': node.cy,
        };
      },
    );
    DocxRegistry().setFromJson<Extent>(
      (Map<String, dynamic> body, metadata) {
        return Extent(
          cx: body['cx'],
          cy: body['cy'],
        );
      },
    );

    DocxRegistry().setToJson<Offset>(
      (Offset node) {
        return <String, dynamic>{
          'x': node.x,
          'y': node.y,
        };
      },
    );
    DocxRegistry().setFromJson<Offset>(
      (Map<String, dynamic> body, metadata) {
        return Offset(
          x: body['x'],
          y: body['y'],
        );
      },
    );

    DocxRegistry().setToJson<Color>((Color node) {
      return <String, dynamic>{
        'type': node.type.index,
        'rgbValue': node.rgbValue,
        'alpha': node.alpha,
        'themeColor': node.themeColor,
        'systemColor': node.systemColor?.index,
      };
    });
    DocxRegistry().setFromJson<Color>((Map<String, dynamic> body, metadata) {
      final ColorType type = ColorType.values[body['type'] as int];
      if (type == ColorType.theme) {
        return Color.theme(body['themeColor'] as String);
      }
      if (type == ColorType.system) {
        return Color.system(SystemColor.values[body['systemColor'] as int]);
      }
      final int alpha = body['alpha'] as int? ?? -1;
      final int rgb = body['rgbValue'] as int? ?? 0;
      final int value = alpha > 0 ? (alpha << 24) | rgb : rgb;
      return Color(value);
    });

    DocxRegistry().setToJson<BorderSide>((BorderSide node) {
      return <String, dynamic>{
        'style': node.style.index,
        'size': node.size.value,
        'space': node.space.value,
        'color': node.color != null ? DocxRegistry().toJson(node.color!) : null,
      };
    });
    DocxRegistry()
        .setFromJson<BorderSide>((Map<String, dynamic> body, metadata) {
      return BorderSide(
        style: BorderStyle.values[body['style'] as int],
        size: Point(body['size'] ?? 4),
        space: Point(body['space'] ?? 0),
        color: body['color'] != null
            ? DocxRegistry()
                .fromJson<Color>(body['color'] as Map<String, dynamic>)
            : null,
      );
    });

    DocxRegistry().setToJson<TableBorders>((TableBorders node) {
      return <String, dynamic>{
        'top': node.top != null ? DocxRegistry().toJson(node.top!) : null,
        'right': node.right != null ? DocxRegistry().toJson(node.right!) : null,
        'bottom':
            node.bottom != null ? DocxRegistry().toJson(node.bottom!) : null,
        'left': node.left != null ? DocxRegistry().toJson(node.left!) : null,
        'insideHorizontal': node.insideHorizontal != null
            ? DocxRegistry().toJson(node.insideHorizontal!)
            : null,
        'insideVertical': node.insideVertical != null
            ? DocxRegistry().toJson(node.insideVertical!)
            : null,
      };
    });
    DocxRegistry().setFromJson<TableBorders>((
      Map<String, dynamic> body,
      Map<String, dynamic>? metadata,
    ) {
      return TableBorders(
        top: body['top'] != null
            ? DocxRegistry()
                .fromJson<BorderSide>(body['top'] as Map<String, dynamic>)
            : null,
        right: body['right'] != null
            ? DocxRegistry()
                .fromJson<BorderSide>(body['right'] as Map<String, dynamic>)
            : null,
        bottom: body['bottom'] != null
            ? DocxRegistry()
                .fromJson<BorderSide>(body['bottom'] as Map<String, dynamic>)
            : null,
        left: body['left'] != null
            ? DocxRegistry()
                .fromJson<BorderSide>(body['left'] as Map<String, dynamic>)
            : null,
        insideHorizontal: body['insideHorizontal'] != null
            ? DocxRegistry().fromJson<BorderSide>(
                body['insideHorizontal'] as Map<String, dynamic>)
            : null,
        insideVertical: body['insideVertical'] != null
            ? DocxRegistry().fromJson<BorderSide>(
                body['insideVertical'] as Map<String, dynamic>)
            : null,
      );
    });

    DocxRegistry().setToJson<TableCellBorders>((TableCellBorders node) {
      return <String, dynamic>{
        'top': node.top != null ? DocxRegistry().toJson(node.top!) : null,
        'right': node.right != null ? DocxRegistry().toJson(node.right!) : null,
        'bottom':
            node.bottom != null ? DocxRegistry().toJson(node.bottom!) : null,
        'left': node.left != null ? DocxRegistry().toJson(node.left!) : null,
      };
    });
    DocxRegistry().setFromJson<TableCellBorders>((
      Map<String, dynamic> body,
      Map<String, dynamic>? metadata,
    ) {
      return TableCellBorders(
        top: body['top'] != null
            ? DocxRegistry()
                .fromJson<BorderSide>(body['top'] as Map<String, dynamic>)
            : null,
        right: body['right'] != null
            ? DocxRegistry()
                .fromJson<BorderSide>(body['right'] as Map<String, dynamic>)
            : null,
        bottom: body['bottom'] != null
            ? DocxRegistry()
                .fromJson<BorderSide>(body['bottom'] as Map<String, dynamic>)
            : null,
        left: body['left'] != null
            ? DocxRegistry()
                .fromJson<BorderSide>(body['left'] as Map<String, dynamic>)
            : null,
      );
    });

    DocxRegistry().setToJson<Shading>((Shading node) {
      return <String, dynamic>{
        'style': node.style.index,
        'color': node.color != null ? DocxRegistry().toJson(node.color!) : null,
        'fill': node.fill != null ? DocxRegistry().toJson(node.fill!) : null,
      };
    });
    DocxRegistry().setFromJson<Shading>((
      Map<String, dynamic> body,
      Map<String, dynamic>? metadata,
    ) {
      return Shading(
        style: ShadingPattern.values[body['style'] as int? ?? 0],
        color: body['color'] != null
            ? DocxRegistry()
                .fromJson<Color>(body['color'] as Map<String, dynamic>)
            : null,
        fill: body['fill'] != null
            ? DocxRegistry()
                .fromJson<Color>(body['fill'] as Map<String, dynamic>)
            : null,
      );
    });

    DocxRegistry().setToJson<TextStyle>((TextStyle node) {
      return <String, dynamic>{
        'bold': node.bold,
        'italic': node.italic,
        'underline': node.underline,
        'strikethrough': node.strikethrough,
        'smallCaps': node.smallCaps,
        'caps': node.caps,
        'fontSize': node.fontSize?.toPt(),
        'fontFamily': node.fontFamily,
        'fontColor': node.fontColor != null
            ? DocxRegistry().toJson(node.fontColor!)
            : null,
        'backgroundColor': node.backgroundColor != null
            ? DocxRegistry().toJson(node.backgroundColor!)
            : null,
        'spacingBefore': node.spacingBefore?.toTwips(),
        'spacingAfter': node.spacingAfter?.toTwips(),
        'lineSpacing': node.lineSpacing?.toTwips(),
        'lineSpacingRule': node.lineSpacingRule?.index,
        'indentLeft': node.indentLeft?.toTwips(),
        'indentRight': node.indentRight?.toTwips(),
        'firstLineIndent': node.firstLineIndent?.toTwips(),
        'hangingIndent': node.hangingIndent?.toTwips(),
        'headingLevel': node.headingLevel,
        'shadingColor': node.shadingColor != null
            ? DocxRegistry().toJson(node.shadingColor!)
            : null,
        'shadingPattern': node.shadingPattern?.index,
        'textAlign': node.textAlign.index,
        'widowControl': node.widowControl != null
            ? <String, dynamic>{
                'controlLines': node.widowControl!.controlLines,
                'lines': node.widowControl!.lines,
              }
            : null,
        'keepNext': node.keepNext,
        'keepLines': node.keepLines,
        'outlineLevel': node.outlineLevel,
      };
    });
    DocxRegistry()
        .setFromJson<TextStyle>((Map<String, dynamic> body, metadata) {
      final widowMap = body['widowControl'] as Map<String, dynamic>?;
      return TextStyle(
        bold: body['bold'] as bool? ?? false,
        italic: body['italic'] as bool? ?? false,
        underline: body['underline'] as bool? ?? false,
        strikethrough: body['strikethrough'] as bool? ?? false,
        smallCaps: body['smallCaps'] as bool? ?? false,
        caps: body['caps'] as bool? ?? false,
        fontSize:
            body['fontSize'] != null ? Point(body['fontSize'] as num) : null,
        fontFamily: body['fontFamily'] as String?,
        fontColor: body['fontColor'] != null
            ? DocxRegistry()
                .fromJson<Color>(body['fontColor'] as Map<String, dynamic>)
            : null,
        backgroundColor: body['backgroundColor'] != null
            ? DocxRegistry().fromJson<Color>(
                body['backgroundColor'] as Map<String, dynamic>)
            : null,
        spacingBefore: body['spacingBefore'] != null
            ? Twip(body['spacingBefore'] as num)
            : null,
        spacingAfter: body['spacingAfter'] != null
            ? Twip(body['spacingAfter'] as num)
            : null,
        lineSpacing: body['lineSpacing'] != null
            ? Twip(body['lineSpacing'] as num)
            : null,
        lineSpacingRule: body['lineSpacingRule'] != null
            ? LineRule.values[body['lineSpacingRule'] as int]
            : null,
        indentLeft:
            body['indentLeft'] != null ? Twip(body['indentLeft'] as num) : null,
        indentRight: body['indentRight'] != null
            ? Twip(body['indentRight'] as num)
            : null,
        firstLineIndent: body['firstLineIndent'] != null
            ? Twip(body['firstLineIndent'] as num)
            : null,
        hangingIndent: body['hangingIndent'] != null
            ? Twip(body['hangingIndent'] as num)
            : null,
        headingLevel: body['headingLevel'] as int?,
        shadingColor: body['shadingColor'] != null
            ? DocxRegistry()
                .fromJson<Color>(body['shadingColor'] as Map<String, dynamic>)
            : null,
        shadingPattern: body['shadingPattern'] != null
            ? ShadingPattern.values[body['shadingPattern'] as int]
            : null,
        textAlign: TextAlign.values[body['textAlign'] as int? ?? 0],
        widowControl: widowMap != null
            ? WidowOrphanControl(
                controlLines: widowMap['controlLines'] as bool? ?? true,
                lines: widowMap['lines'] as int? ?? 2,
              )
            : null,
        keepNext: body['keepNext'] as bool?,
        keepLines: body['keepLines'] as bool?,
        outlineLevel: body['outlineLevel'] as int?,
      );
    });

    DocxRegistry().setToJson<DocProperties>(
      (DocProperties node) {
        return <String, dynamic>{
          'id': node.id,
          'name': node.name,
          'description': node.description,
          'relativeHeight': node.relativeHeight,
        };
      },
    );
    DocxRegistry().setFromJson<DocProperties>(
      (Map<String, dynamic> body, metadata) {
        return DocProperties(
          docPrId: body['id'],
          name: body['name'],
          description: body['description'],
          relativeHeight: body['relativeHeight'],
        );
      },
    );

    DocxRegistry().setToJson<Break>(
      (Break node) {
        return <String, dynamic>{
          'id': node.id,
          'child': node.child.index,
        };
      },
    );
    DocxRegistry().setFromJson<Break>(
      (Map<String, dynamic> body, metadata) {
        return Break(
          id: body['id'],
          child: BreakType.values[body['child'] as int],
        );
      },
    );

    DocxRegistry().setToJson<Align>(
      (Align node) {
        return <String, dynamic>{
          'id': node.id,
          'child': DocxRegistry().toJson(node.child),
          'alignment': node.alignment.index,
        };
      },
    );
    DocxRegistry().setFromJson<Align>(
      (Map<String, dynamic> body, metadata) {
        return Align(
          id: body['id'],
          alignment: Alignment.values[body['alignment']],
          child: DocxRegistry().fromJson(body['child']) as DocxNode<dynamic>,
        );
      },
    );

    DocxRegistry().setToJson<Column>(
      (Column node) {
        return <String, dynamic>{
          'id': node.id,
          'children': <Map<String, dynamic>>[
            ...node.child.map<Map<String, dynamic>>((
              DocxNode<dynamic> e,
            ) =>
                DocxRegistry().toJson(e)!),
          ],
          'width': node.width,
          'align': node.align?.index,
          'fixedWidth': node.fixedWidth,
        };
      },
    );
    DocxRegistry().setFromJson<Column>(
      (Map<String, dynamic> body, metadata) {
        return Column(
          id: body['id'],
          children: <DocxNode<dynamic>>[
            ...?body['children']?.cast<Iterable<Map<String, dynamic>>>().map((
                  Map<String, dynamic> child,
                ) =>
                    DocxRegistry().fromJson(child)?.cast<DocxNode<dynamic>>()),
          ],
          width: body['width'],
          align: body['align'] != null ? Alignment.values[body['align']] : null,
          fixedWidth: body['fixedWidth'],
        );
      },
    );

    DocxRegistry().setToJson<Padding>(
      (Padding node) {
        return <String, dynamic>{
          'id': node.id,
          'child': DocxRegistry().toJson(node.child),
          'padding': <String, dynamic>{
            'top': node.padding.top?.toTwips(),
            'right': node.padding.right?.toTwips(),
            'bottom': node.padding.bottom?.toTwips(),
            'left': node.padding.left?.toTwips(),
          },
        };
      },
    );
    DocxRegistry().setFromJson<Padding>(
      (Map<String, dynamic> body, metadata) {
        final paddingMap = body['padding'] as Map<String, dynamic>;
        return Padding(
          id: body['id'],
          padding: EdgeInsets(
            top: paddingMap['top'] != null ? Twip(paddingMap['top']) : null,
            right:
                paddingMap['right'] != null ? Twip(paddingMap['right']) : null,
            bottom: paddingMap['bottom'] != null
                ? Twip(paddingMap['bottom'])
                : null,
            left: paddingMap['left'] != null ? Twip(paddingMap['left']) : null,
          ),
          child: DocxRegistry().fromJson(body['child']) as DocxNode<dynamic>,
        );
      },
    );

    DocxRegistry().setToJson<TableProperties>(
      (TableProperties node) {
        return <String, dynamic>{
          'styles': node.styles.map<Map<String, dynamic>>((Style s) {
            return DocxRegistry().toJson(s)!;
          }).toList(),
          'width': node.width,
          'widthType': node.widthType.index,
          'alignment': node.alignment?.index,
          'layout': node.layout,
          'borders': node.borders != null
              ? DocxRegistry().toJson(node.borders!)
              : null,
          'cellMargins': node.cellMargins != null
              ? <String, dynamic>{
                  'top': node.cellMargins!.top?.toTwips(),
                  'right': node.cellMargins!.right?.toTwips(),
                  'bottom': node.cellMargins!.bottom?.toTwips(),
                  'left': node.cellMargins!.left?.toTwips(),
                }
              : null,
        };
      },
    );
    DocxRegistry().setFromJson<TableProperties>(
      (Map<String, dynamic> body, metadata) {
        final stylesList = body['styles'] as List<dynamic>?;
        final cellMarginsMap = body['cellMargins'] as Map<String, dynamic>?;

        return TableProperties(
          styles: stylesList
                  ?.map<Style>((s) => DocxRegistry()
                      .fromJson<Style>(s as Map<String, dynamic>)!)
                  .toList() ??
              [],
          width: body['width'] ?? 0,
          widthType: TableWidthType.values[body['widthType'] ?? 0],
          alignment: body['alignment'] != null
              ? Alignment.values[body['alignment']]
              : null,
          layout: body['layout'] ?? false,
          borders: body['borders'] != null
              ? DocxRegistry().fromJson<TableBorders>(
                  body['borders'] as Map<String, dynamic>)
              : null,
          padding: cellMarginsMap != null
              ? EdgeInsets(
                  top: cellMarginsMap['top'] != null
                      ? Twip(cellMarginsMap['top'])
                      : null,
                  right: cellMarginsMap['right'] != null
                      ? Twip(cellMarginsMap['right'])
                      : null,
                  bottom: cellMarginsMap['bottom'] != null
                      ? Twip(cellMarginsMap['bottom'])
                      : null,
                  left: cellMarginsMap['left'] != null
                      ? Twip(cellMarginsMap['left'])
                      : null,
                )
              : null,
        );
      },
    );

    DocxRegistry().setToJson<Table>(
      (Table node) {
        return <String, dynamic>{
          'id': node.id,
          'children': <Map<String, dynamic>>[
            ...node.child.map<Map<String, dynamic>>((
              TableRow e,
            ) =>
                DocxRegistry().toJson(e)!),
          ],
          'columns': <Map<String, dynamic>>[
            ...node.columns
                .map<Map<String, dynamic>>((GridColumn e) => <String, dynamic>{
                      'width': e.width,
                    }),
          ],
          'tableProperties': node.tableProperties != null
              ? DocxRegistry().toJson(
                  node.tableProperties!,
                ) as Map<String, dynamic>
              : null,
        };
      },
    );
    DocxRegistry().setFromJson<Table>(
      (
        Map<String, dynamic> body,
        Map<String, dynamic>? metadata,
      ) {
        return Table(
          id: body['id'],
          rows: <TableRow>[
            ...?body['children']?.cast<Iterable<Map<String, dynamic>>>().map((
                  Map<String, dynamic> child,
                ) =>
                    DocxRegistry().fromJson(child)?.cast<TableRow>()),
          ],
          columns: <GridColumn>[
            ...?body['columns']?.cast<Iterable<Map<String, dynamic>>>().map((
                  Map<String, dynamic> col,
                ) =>
                    GridColumn(width: col['width'])),
          ],
          tableProperties: body['tableProperties'] != null
              ? DocxRegistry().fromJson(body['tableProperties'])
                  as TableProperties?
              : null,
        );
      },
    );

    DocxRegistry().setToJson<Style>(
      (Style node) {
        return <String, dynamic>{
          'id': node.id,
          'type': node.type,
          'styleId': node.styleId,
          // style must always have a primary type of data
          // as its defaultValue
          'defaultValue': node.defaultValue,
          'revisionIdDefault': node.revisionIdDefault,
          'revisionIdPPr': node.revisionIdPPr,
          'revisionIdRun': node.revisionIdRun,
          'revisionIdRPr': node.revisionIdRPr,
          'isReference': node.isReference,
          'configurators': node.configurators
              .map<Map<String, dynamic>>((StyleConfigurator c) {
            return DocxRegistry().toJson(c)!;
          }).toList(),
        };
      },
    );
    DocxRegistry().setFromJson<Style>(
      (
        Map<String, dynamic> body,
        Map<String, dynamic>? metadata,
      ) {
        if (body['isReference'] == true) {
          return Style.ref(
            body['styleId'].cast<String>(),
            body['id'].castOrNull<String>(),
          );
        }
        final List<dynamic>? configuratorsList =
            body['configurators'].cast<List<dynamic>>();
        return Style(
          id: body['id'] ?? '',
          type: body['type'] ?? '',
          styleId: body['styleId'] ?? '',
          defaultValue: body['defaultValue'],
          revisionIdDefault: body['revisionIdDefault'],
          revisionIdPPr: body['revisionIdPPr'],
          revisionIdRun: body['revisionIdRun'],
          revisionIdRPr: body['revisionIdRPr'],
          configurators: configuratorsList
                  ?.map<StyleConfigurator>((c) => DocxRegistry()
                      .fromJson<StyleConfigurator>(c as Map<String, dynamic>)!)
                  .toList() ??
              [],
        );
      },
    );

    DocxRegistry().setToJson<StyleConfigurator>(
      (StyleConfigurator node) {
        return <String, dynamic>{
          'propertyName': node.propertyName,
          'prefix': node.prefix,
          'value': node.value,
          'attributes': node.attributes,
          'isSelfClosing': node.isSelfClosing,
          'configurators': node.configurators
              .map<Map<String, dynamic>>((StyleConfigurator c) {
            return DocxRegistry().toJson(c)!;
          }).toList(),
        };
      },
    );
    DocxRegistry().setFromJson<StyleConfigurator>(
      (Map<String, dynamic> body, metadata) {
        final configuratorsList = body['configurators'] as List<dynamic>?;
        final isSelfClosing = body['isSelfClosing'] ?? true;
        if (isSelfClosing) {
          return StyleConfigurator.selfClosing(
            propertyName: body['propertyName'] ?? '',
            prefix: body['prefix'],
            value: body['value'],
            attributes: body['attributes'] != null
                ? Map<String, dynamic>.from(body['attributes'])
                : null,
          );
        }
        return StyleConfigurator.noSelfClosing(
          propertyName: body['propertyName'] ?? '',
          prefix: body['prefix'],
          value: body['value'],
          attributes: body['attributes'] != null
              ? Map<String, dynamic>.from(body['attributes'])
              : null,
          configurators: configuratorsList
                  ?.map<StyleConfigurator>((c) => DocxRegistry()
                      .fromJson<StyleConfigurator>(c as Map<String, dynamic>)!)
                  .toList() ??
              [],
        );
      },
    );

    DocxRegistry().setToJson<LatentStyles>(
      (LatentStyles node) {
        return <String, dynamic>{
          'defSemiHidden': node.defSemiHidden,
          'defUnhideWhenUsed': node.defUnhideWhenUsed,
          'defLockedState': node.defLockedState,
          'defQFormat': node.defQFormat,
          'defUIPriority': node.defUIPriority,
          'count': node.count,
          'exceptions':
              node.exceptions.map<Map<String, dynamic>>((LatentException e) {
            return DocxRegistry().toJson(e)!;
          }).toList(),
        };
      },
    );
    DocxRegistry().setFromJson<LatentStyles>(
      (Map<String, dynamic> body, metadata) {
        final exceptionsList = body['exceptions'] as List<dynamic>?;
        return LatentStyles(
          defSemiHidden: body['defSemiHidden'] ?? true,
          defUnhideWhenUsed: body['defUnhideWhenUsed'] ?? true,
          defLockedState: body['defLockedState'] ?? false,
          defQFormat: body['defQFormat'] ?? false,
          defUIPriority: body['defUIPriority'] ?? 9,
          count: body['count'] ?? 0,
          exceptions: exceptionsList
                  ?.map<LatentException>((e) => DocxRegistry()
                      .fromJson<LatentException>(e as Map<String, dynamic>)!)
                  .toList() ??
              [],
        );
      },
    );

    DocxRegistry().setToJson<LatentException>(
      (LatentException node) {
        return <String, dynamic>{
          'styleName':
              node.attributes.xmlAttributes['w:name']?.toString() ?? '',
          'metadata': Map<String, Object>.from(node.attributes.xmlAttributes),
        };
      },
    );
    DocxRegistry().setFromJson<LatentException>(
      (Map<String, dynamic> body, metadata) {
        return LatentException(
          styleName: body['styleName'] ?? '',
          metadata: body['metadata'] != null
              ? Map<String, Object>.from(body['metadata'])
              : <String, Object>{},
        );
      },
    );

    DocxRegistry().setToJson<TextRun>(
      (TextRun node) {
        return <String, dynamic>{
          'id': node.id,
          'text': node.child.text,
          'styles': node.child.styles.map<Map<String, dynamic>>((Object s) {
            if (s is Style) return DocxRegistry().toJson(s)!;
            return <String, dynamic>{};
          }).toList(),
          'textStyle': node.textStyle != null
              ? DocxRegistry().toJson(node.textStyle!)
              : null,
        };
      },
    );
    DocxRegistry().setFromJson<TextRun>(
      (Map<String, dynamic> body, metadata) {
        final stylesList = body['styles'] as List<dynamic>? ?? [];
        final textStyleMap = body['textStyle'] as Map<String, dynamic>?;
        return TextRun(
          id: body['id'],
          textPart: TextPart(
            text: body['text'] as String? ?? '',
            styles: stylesList.map<Style>((dynamic s) {
              final Style style = DocxRegistry().fromJson<Style>(
                s.cast<Map<String, dynamic>>(),
              )!;
              return style;
            }).toList(),
          ),
          textStyle: textStyleMap != null
              ? DocxRegistry().fromJson<TextStyle>(textStyleMap)
              : null,
        );
      },
    );

    DocxRegistry()
      ..setToJson<Numbering>((Numbering node) {
        return <String, dynamic>{
          'refId': node.refId,
          'level': node.level,
          'reference': node.reference,
        };
      })
      ..setFromJson<Numbering>((Map<String, dynamic> body, metadata) {
        return Numbering(
          reference: body['reference'],
          refId: body['refId'],
          level: body['level'],
        );
      });

    DocxRegistry()
      ..setToJson<Paragraph>(
        (Paragraph node) {
          return <String, dynamic>{
            'id': node.id,
            'children': <Map<String, dynamic>>[
              ...node.child.map<Map<String, dynamic>>((
                RunBase<dynamic> e,
              ) =>
                  DocxRegistry().toJson(e)!),
            ],
            'alignment': node.alignment?.index,
            'pageBreak': node.pageBreak.index,
            'numbering': node.numbering != null
                ? DocxRegistry().toJson(node.numbering!)
                : null,
            'textStyle': node.textStyle != null
                ? DocxRegistry().toJson(node.textStyle!)
                : null,
            'styles': node.styles.map<Map<String, dynamic>>((Style s) {
              return DocxRegistry().toJson(s)!;
            }).toList(),
          };
        },
      )
      ..setFromJson<Paragraph>(
        (Map<String, dynamic> body, metadata) {
          final stylesList = body['styles'] as List<dynamic>? ?? [];
          final numberingMap = body['numbering'] as Map<String, dynamic>?;
          final textStyleMap = body['textStyle'] as Map<String, dynamic>?;
          return Paragraph(
            id: body['id'],
            children: <RunBase<dynamic>>[
              ...?body['children']?.cast<Iterable<Map<String, dynamic>>>().map((
                    Map<String, dynamic> child,
                  ) =>
                      DocxRegistry().fromJson(child)?.cast<RunBase>()),
            ],
            alignment: body['alignment'] != null
                ? Alignment.values[body['alignment'] as int]
                : null,
            pageBreak:
                ParagraphPageBreak.values[body['pageBreak'] as int? ?? 2],
            numbering: numberingMap != null
                ? DocxRegistry().fromJson<Numbering>(numberingMap)
                : null,
            textStyle: textStyleMap != null
                ? DocxRegistry().fromJson<TextStyle>(textStyleMap)
                : null,
            styles: stylesList
                .map<Style>((s) =>
                    DocxRegistry().fromJson<Style>(s as Map<String, dynamic>)!)
                .toList(),
          );
        },
      );

    DocxRegistry().setToJson<PageBreak>(
      (PageBreak node) {
        return <String, dynamic>{
          'type': node.type,
          'id': node.id,
        };
      },
    );
    DocxRegistry().setFromJson<PageBreak>(
      (Map<String, dynamic> body, metadata) {
        return PageBreak(
          body['type'],
          body['id'],
        );
      },
    );

    DocxRegistry().setToJson<Run>(
      (Run node) {
        return <String, dynamic>{
          'id': node.id,
          'child': DocxRegistry().toJson(node.child),
          'wrapInRunMark': node.wrapInRunMark,
        };
      },
    );
    DocxRegistry().setFromJson<Run>(
      (Map<String, dynamic> body, metadata) {
        return Run(
          id: body['id'],
          component:
              DocxRegistry().fromJson(body['child']) as DocxNode<dynamic>,
          wrapInRunMark: body['wrapInRunMark'] ?? true,
        );
      },
    );

    DocxRegistry().setToJson<Anchor>(
      (Anchor node) {
        return <String, dynamic>{
          'id': node.id,
          'child': DocxRegistry().toJson(node.child),
          'width': node.width,
          'height': node.height,
          'name': node.name,
          'elementId': node.elementId,
        };
      },
    );
    DocxRegistry().setFromJson<Anchor>(
      (
        Map<String, dynamic> body,
        Map<String, dynamic>? metadata,
      ) {
        return Anchor(
          id: body['id'],
          child: DocxRegistry().fromJson(body['child']) as DocxNode<dynamic>,
          width: body['width'] ?? 0,
          height: body['height'] ?? 0,
          name: body['name'] ?? '',
          config: AnchorConfig.inline(),
          elementId: body['elementId'],
        );
      },
    );

    DocxRegistry().setToJson<TableRow>(
      (TableRow node) {
        return <String, dynamic>{
          'id': node.id,
          'children': <Map<String, dynamic>>[
            ...node.child.map<Map<String, dynamic>>((
              TableCell e,
            ) =>
                DocxRegistry().toJson(e)!),
          ],
          'canSplit': node.canSplit,
          'hidden': node.hidden,
          'height': node.height,
          'heightRule': node.heightRule?.index,
          'alignment': node.alignment?.index,
          'spacing': node.spacing.value,
          'isHeader': node.isHeader,
        };
      },
    );
    DocxRegistry().setFromJson<TableRow>(
      (
        Map<String, dynamic> body,
        Map<String, dynamic>? metadata,
      ) {
        return TableRow(
          id: body['id'],
          cells: <TableCell>[
            ...?body['children']?.cast<Iterable<Map<String, dynamic>>>().map((
                  Map<String, dynamic> child,
                ) =>
                    DocxRegistry().fromJson(child)?.cast<TableCell>()),
          ],
          canSplit: body['canSplit'],
          hidden: body['hidden'],
          height: body['height'],
          heightRule: body['heightRule'] != null
              ? TableHeightRule.values[body['heightRule']]
              : null,
          alignment: body['alignment'] != null
              ? Alignment.values[body['alignment']]
              : null,
          spacing: Dxa(body['spacing'] ?? 0),
          isHeader: body['isHeader'] ?? false,
        );
      },
    );

    DocxRegistry().setToJson<TableCellConfig>(
      (TableCellConfig node) {
        return <String, dynamic>{
          'width': node.width,
          'widthType': node.widthType.index,
          'columnSpan': node.columnSpan,
          'rowSpan': node.rowSpan,
          'verticalAlignment': node.verticalAlignment?.index,
          'borders': node.borders != null
              ? DocxRegistry().toJson(node.borders!)
              : null,
          'shading': node.shading != null
              ? DocxRegistry().toJson(node.shading!)
              : null,
        };
      },
    );
    DocxRegistry().setFromJson<TableCellConfig>(
      (
        Map<String, dynamic> body,
        Map<String, dynamic>? metadata,
      ) {
        final widthType = TableWidthType.values[body['widthType'] as int? ?? 1];
        return switch (widthType) {
          TableWidthType.dxa => TableCellConfig.dxa(
              width: body['width'] ?? 0,
              columnSpan: body['columnSpan'],
              rowSpan: body['rowSpan'],
              verticalAlignment: body['verticalAlignment'] != null
                  ? VerticalAlignment.values[body['verticalAlignment']]
                  : null,
              borders: body['borders'] != null
                  ? DocxRegistry().fromJson<TableCellBorders>(
                      body['borders'] as Map<String, dynamic>)
                  : null,
              shading: body['shading'] != null
                  ? DocxRegistry().fromJson<Shading>(
                      body['shading'] as Map<String, dynamic>)
                  : null,
            ),
          TableWidthType.pct => TableCellConfig.pct(
              width: body['width'] ?? 0,
              columnSpan: body['columnSpan'],
              rowSpan: body['rowSpan'],
              verticalAlignment: body['verticalAlignment'] != null
                  ? VerticalAlignment.values[body['verticalAlignment']]
                  : null,
              borders: body['borders'] != null
                  ? DocxRegistry().fromJson<TableCellBorders>(
                      body['borders'] as Map<String, dynamic>)
                  : null,
              shading: body['shading'] != null
                  ? DocxRegistry().fromJson<Shading>(
                      body['shading'] as Map<String, dynamic>)
                  : null,
            ),
          TableWidthType.auto => TableCellConfig.auto(
              columnSpan: body['columnSpan'],
              rowSpan: body['rowSpan'],
              verticalAlignment: body['verticalAlignment'] != null
                  ? VerticalAlignment.values[body['verticalAlignment']]
                  : null,
              borders: body['borders'] != null
                  ? DocxRegistry().fromJson<TableCellBorders>(
                      body['borders'] as Map<String, dynamic>)
                  : null,
              shading: body['shading'] != null
                  ? DocxRegistry().fromJson<Shading>(
                      body['shading'] as Map<String, dynamic>)
                  : null,
            ),
          TableWidthType.nil => TableCellConfig.nil(
              columnSpan: body['columnSpan'],
              rowSpan: body['rowSpan'],
              verticalAlignment: body['verticalAlignment'] != null
                  ? VerticalAlignment.values[body['verticalAlignment']]
                  : null,
              borders: body['borders'] != null
                  ? DocxRegistry().fromJson<TableCellBorders>(
                      body['borders'] as Map<String, dynamic>)
                  : null,
              shading: body['shading'] != null
                  ? DocxRegistry().fromJson<Shading>(
                      body['shading'] as Map<String, dynamic>)
                  : null,
            ),
          _ => TableCellConfig.dxa(
              width: body['width'] ?? 0,
              columnSpan: body['columnSpan'],
              rowSpan: body['rowSpan'],
              verticalAlignment: body['verticalAlignment'] != null
                  ? VerticalAlignment.values[body['verticalAlignment']]
                  : null,
              borders: body['borders'] != null
                  ? DocxRegistry().fromJson<TableCellBorders>(
                      body['borders'] as Map<String, dynamic>)
                  : null,
              shading: body['shading'] != null
                  ? DocxRegistry().fromJson<Shading>(
                      body['shading'] as Map<String, dynamic>)
                  : null,
            ),
        };
      },
    );

    DocxRegistry().setToJson<TableCell>(
      (TableCell node) {
        return <String, dynamic>{
          'id': node.id,
          'children': <Map<String, dynamic>>[
            ...node.child.map<Map<String, dynamic>>((
              DocxNode<dynamic> e,
            ) =>
                DocxRegistry().toJson(e)!),
          ],
          'cellConfig': DocxRegistry().toJson(node.cellConfig),
        };
      },
    );
    DocxRegistry().setFromJson<TableCell>(
      (
        Map<String, dynamic> body,
        Map<String, dynamic>? metadata,
      ) {
        final Map<String, dynamic>? cellConfigMap =
            body['cellConfig'] as Map<String, dynamic>?;
        return TableCell(
          id: body['id'],
          children: <DocxNode<dynamic>>[
            ...?body['children']?.cast<Iterable<Map<String, dynamic>>>().map((
                  Map<String, dynamic> child,
                ) =>
                    DocxRegistry().fromJson(child)?.cast<DocxNode>()),
          ],
          cellConfig: cellConfigMap != null
              ? DocxRegistry().fromJson<TableCellConfig>(cellConfigMap)!
              : const TableCellConfig.auto(),
        );
      },
    );

    DocxRegistry().setToJson<SdtListItem>(
      (SdtListItem node) {
        return <String, dynamic>{
          'id': node.id,
          'displayText': node.displayText,
          'value': node.value,
        };
      },
    );
    DocxRegistry().setFromJson<SdtListItem>(
      (
        Map<String, dynamic> body,
        Map<String, dynamic>? metadata,
      ) {
        return SdtListItem(
          id: body['id'],
          displayText: body['displayText'] ?? '',
          value: body['value'] ?? '',
        );
      },
    );

    DocxRegistry().setToJson<SdtPlainText>(
      (SdtPlainText node) {
        return <String, dynamic>{
          'id': node.id,
          'alias': node.alias,
          'tag': node.tag,
          'placeholder': node.placeholder,
          'showingPlacHdr': node.showingPlacHdr,
          'maxLength': node.maxLength,
          'lock': node.lock?.index,
          'temporary': node.temporary,
          'sdtId': node.sdtId,
          'content': (node.child)
              .map<Map<String, dynamic>>(
                  (RunBase e) => DocxRegistry().toJson(e)!)
              .toList(),
        };
      },
    );
    DocxRegistry().setFromJson<SdtPlainText>(
      (
        Map<String, dynamic> body,
        Map<String, dynamic>? metadata,
      ) {
        final List<dynamic> contentList =
            body['content'] as List<dynamic>? ?? [];
        return SdtPlainText(
          id: body['id'],
          alias: body['alias'] ?? '',
          tag: body['tag'] ?? '',
          placeholder: body['placeholder'],
          showingPlacHdr: body['showingPlacHdr'] ?? true,
          maxLength: body['maxLength'],
          lock:
              body['lock'] != null ? StdLock.values[body['lock'] as int] : null,
          temporary: body['temporary'] ?? false,
          sdtId: body['sdtId'],
          content: contentList
              .map<RunBase>((e) => DocxRegistry()
                  .fromJson(e as Map<String, dynamic>)!
                  .cast<RunBase>())
              .toList(),
        );
      },
    );

    DocxRegistry().setToJson<SdtRichText>(
      (SdtRichText node) {
        return <String, dynamic>{
          'id': node.id,
          'alias': node.alias,
          'tag': node.tag,
          'placeholder': node.placeholder,
          'showingPlacHdr': node.showingPlacHdr,
          'lock': node.lock?.index,
          'temporary': node.temporary,
          'sdtId': node.sdtId,
          'content': (node.child)
              .map<Map<String, dynamic>>(
                  (DocxNode e) => DocxRegistry().toJson(e)!)
              .toList(),
        };
      },
    );
    DocxRegistry().setFromJson<SdtRichText>(
      (
        Map<String, dynamic> body,
        Map<String, dynamic>? metadata,
      ) {
        final List<dynamic> contentList =
            body['content'] as List<dynamic>? ?? [];
        return SdtRichText(
          id: body['id'],
          alias: body['alias'] ?? '',
          tag: body['tag'] ?? '',
          placeholder: body['placeholder'],
          showingPlacHdr: body['showingPlacHdr'] ?? true,
          lock:
              body['lock'] != null ? StdLock.values[body['lock'] as int] : null,
          temporary: body['temporary'] ?? false,
          sdtId: body['sdtId'],
          content: contentList
              .map<DocxNode>((e) => DocxRegistry()
                  .fromJson(e as Map<String, dynamic>)!
                  .cast<DocxNode>())
              .toList(),
        );
      },
    );

    DocxRegistry().setToJson<SdtDropDownList>(
      (SdtDropDownList node) {
        return <String, dynamic>{
          'id': node.id,
          'alias': node.alias,
          'tag': node.tag,
          'selectedValue': node.selectedValue,
          'placeholder': node.placeholder,
          'showingPlacHdr': node.showingPlacHdr,
          'lock': node.lock?.index,
          'temporary': node.temporary,
          'sdtId': node.sdtId,
          'items': node.items
              .map<Map<String, dynamic>>(
                  (SdtListItem e) => DocxRegistry().toJson(e)!)
              .toList(),
        };
      },
    );
    DocxRegistry().setFromJson<SdtDropDownList>(
      (Map<String, dynamic> body, metadata) {
        final itemsList = body['items'] as List<dynamic>? ?? [];
        return SdtDropDownList(
          id: body['id'],
          alias: body['alias'] ?? '',
          tag: body['tag'] ?? '',
          items: itemsList
              .map<SdtListItem>((e) => DocxRegistry()
                  .fromJson(e as Map<String, dynamic>)!
                  .cast<SdtListItem>())
              .toList(),
          selectedValue: body['selectedValue'],
          placeholder: body['placeholder'],
          showingPlacHdr: body['showingPlacHdr'] ?? true,
          lock:
              body['lock'] != null ? StdLock.values[body['lock'] as int] : null,
          temporary: body['temporary'] ?? false,
          sdtId: body['sdtId'],
        );
      },
    );

    DocxRegistry().setToJson<SdtComboBox>(
      (SdtComboBox node) {
        return <String, dynamic>{
          'id': node.id,
          'alias': node.alias,
          'tag': node.tag,
          'selectedValue': node.selectedValue,
          'placeholder': node.placeholder,
          'showingPlacHdr': node.showingPlacHdr,
          'lock': node.lock?.index,
          'temporary': node.temporary,
          'sdtId': node.sdtId,
          'items': node.child
              .map<Map<String, dynamic>>(
                  (SdtListItem e) => DocxRegistry().toJson(e)!)
              .toList(),
        };
      },
    );
    DocxRegistry().setFromJson<SdtComboBox>(
      (Map<String, dynamic> body, metadata) {
        final itemsList = body['items'] as List<dynamic>? ?? [];
        return SdtComboBox(
          id: body['id'],
          alias: body['alias'] ?? '',
          tag: body['tag'] ?? '',
          items: itemsList
              .map<SdtListItem>((e) => DocxRegistry()
                  .fromJson(e as Map<String, dynamic>)!
                  .cast<SdtListItem>())
              .toList(),
          selectedValue: body['selectedValue'],
          placeholder: body['placeholder'],
          showingPlacHdr: body['showingPlacHdr'] ?? true,
          lock:
              body['lock'] != null ? StdLock.values[body['lock'] as int] : null,
          temporary: body['temporary'] ?? false,
          sdtId: body['sdtId'],
        );
      },
    );

    DocxRegistry().setToJson<SdtDate>(
      (SdtDate node) {
        return <String, dynamic>{
          'id': node.id,
          'alias': node.alias,
          'tag': node.tag,
          'dateFormat': node.dateFormat,
          'locale': node.locale,
          'storeMappedDataAs': node.storeMappedDataAs,
          'calendar': node.calendar.index,
          'value': node.value?.toIso8601String(),
          'placeholder': node.placeholder,
          'showingPlacHdr': node.showingPlacHdr,
          'lock': node.lock?.index,
          'temporary': node.temporary,
          'sdtId': node.sdtId,
        };
      },
    );
    DocxRegistry().setFromJson<SdtDate>(
      (Map<String, dynamic> body, metadata) {
        return SdtDate(
          id: body['id'],
          alias: body['alias'] ?? '',
          tag: body['tag'] ?? '',
          dateFormat: body['dateFormat'] ?? 'dd/MM/yyyy',
          locale: body['locale'] ?? 'en-US',
          storeMappedDataAs: body['storeMappedDataAs'] ?? 'dateTime',
          calendar: SdtCalendar.values[body['calendar'] as int? ?? 0],
          value: body['value'] != null
              ? DateTime.tryParse(body['value'] as String)
              : null,
          placeholder: body['placeholder'],
          showingPlacHdr: body['showingPlacHdr'] ?? true,
          lock:
              body['lock'] != null ? StdLock.values[body['lock'] as int] : null,
          temporary: body['temporary'] ?? false,
          sdtId: body['sdtId'],
        );
      },
    );

    DocxRegistry().setToJson<SdtCheckbox>(
      (SdtCheckbox node) {
        return <String, dynamic>{
          'id': node.id,
          'alias': node.alias,
          'tag': node.tag,
          'checked': node.checked,
          'checkedState': node.checkedState.index,
          'uncheckedState': node.uncheckedState.index,
          'placeholder': node.placeholder,
          'showingPlacHdr': node.showingPlacHdr,
          'lock': node.lock?.index,
          'temporary': node.temporary,
          'sdtId': node.sdtId,
        };
      },
    );
    DocxRegistry().setFromJson<SdtCheckbox>(
      (Map<String, dynamic> body, metadata) {
        return SdtCheckbox(
          id: body['id'],
          alias: body['alias'] ?? '',
          tag: body['tag'] ?? '',
          checked: body['checked'] ?? false,
          checkedState:
              SdtCheckboxState.values[body['checkedState'] as int? ?? 0],
          uncheckedState:
              SdtCheckboxState.values[body['uncheckedState'] as int? ?? 1],
          placeholder: body['placeholder'],
          showingPlacHdr: body['showingPlacHdr'] ?? true,
          lock:
              body['lock'] != null ? StdLock.values[body['lock'] as int] : null,
          temporary: body['temporary'] ?? false,
          sdtId: body['sdtId'],
        );
      },
    );

    DocxRegistry().setToJson<SdtPicture>(
      (SdtPicture node) {
        return <String, dynamic>{
          'id': node.id,
          'alias': node.alias,
          'tag': node.tag,
          'placeholder': node.placeholder,
          'showingPlacHdr': node.showingPlacHdr,
          'lock': node.lock?.index,
          'temporary': node.temporary,
          'sdtId': node.sdtId,
          'content': DocxRegistry().toJson(node.child),
        };
      },
    );
    DocxRegistry().setFromJson<SdtPicture>(
      (Map<String, dynamic> body, metadata) {
        return SdtPicture(
          id: body['id'],
          alias: body['alias'] ?? '',
          tag: body['tag'] ?? '',
          placeholder: body['placeholder'],
          showingPlacHdr: body['showingPlacHdr'] ?? true,
          lock:
              body['lock'] != null ? StdLock.values[body['lock'] as int] : null,
          temporary: body['temporary'] ?? false,
          sdtId: body['sdtId'],
          content: body['content'] != null
              ? DocxRegistry()
                  .fromJson(body['content'] as Map<String, dynamic>)
                  ?.cast<RunBase>()
              : null,
        );
      },
    );

    DocxRegistry().setToJson<FloatingImage>(
      (FloatingImage node) {
        return <String, dynamic>{
          'id': node.id,
          'transformOffsetX': node.transformOffsetX,
          'transformOffsetY': node.transformOffsetY,
          //TODO: we need to pass the image data
        };
      },
    );
    DocxRegistry().setFromJson<FloatingImage>(
      (Map<String, dynamic> body, metadata) {
        final bytes = metadata?['bytes'] as Uint8List?;
        return FloatingImage(
          id: body['id'],
          transformOffsetX: body['transformOffsetX'] ?? 0,
          transformOffsetY: body['transformOffsetY'] ?? 0,
          data: ImageData<Uint8List>(
            buffer: bytes!,
            extension: metadata?['extension'] ?? '.png',
            anchorConfig: metadata?['anchorConfig'] ?? AnchorConfig.inline(),
            styles: metadata?['styles'] ?? const [],
            width: metadata?['width'],
            height: metadata?['height'],
            alt: metadata?['alt'],
            name: metadata?['name'],
          ),
        );
      },
    );

    DocxRegistry().setToJson<LazyFloatingImage>(
      (LazyFloatingImage node) {
        final filePath = node.child.buffer.path;
        return <String, dynamic>{
          'id': node.id,
          'transformOffsetX': node.transformOffsetX,
          'transformOffsetY': node.transformOffsetY,
          'filePath': filePath,
          'extension': node.child.extension,
        };
      },
    );
    DocxRegistry().setFromJson<LazyFloatingImage>(
      (Map<String, dynamic> body, metadata) {
        final filePath = body['filePath'] as String? ?? '';
        return LazyFloatingImage(
          id: body['id'],
          transformOffsetX: body['transformOffsetX'] ?? 0,
          transformOffsetY: body['transformOffsetY'] ?? 0,
          data: ImageData<File>(
            buffer: File(filePath),
            extension: body['extension'] ?? '.png',
            anchorConfig: metadata?['anchorConfig'] ?? AnchorConfig.inline(),
            styles: metadata?['styles'] ?? const [],
            width: metadata?['width'],
            height: metadata?['height'],
            alt: metadata?['alt'],
            name: metadata?['name'],
          ),
        );
      },
    );

    DocxRegistry().setToJson<Image>(
      (Image node) {
        return <String, dynamic>{
          'id': node.id,
          'transformOffsetX': node.transformOffsetX,
          'transformOffsetY': node.transformOffsetY,
          'asInline': node.asInline,
        };
      },
    );
    DocxRegistry().setFromJson<Image>(
      (Map<String, dynamic> body, metadata) {
        final bytes = metadata?['bytes'] as Uint8List?;
        return Image(
          id: body['id'],
          transformOffsetX: body['transformOffsetX'] ?? 0,
          transformOffsetY: body['transformOffsetY'] ?? 0,
          asInline: body['asInline'] ?? true,
          data: ImageData<Uint8List>(
            buffer: bytes!,
            extension: metadata?['extension'] ?? '.png',
            anchorConfig: metadata?['anchorConfig'] ?? AnchorConfig.inline(),
            styles: metadata?['styles'] ?? const [],
            width: metadata?['width'],
            height: metadata?['height'],
            alt: metadata?['alt'],
            name: metadata?['name'],
          ),
        );
      },
    );

    DocxRegistry().setToJson<LazyImage>(
      (LazyImage node) {
        final filePath = node.child.buffer..path;
        return <String, dynamic>{
          'id': node.id,
          'transformOffsetX': node.transformOffsetX,
          'transformOffsetY': node.transformOffsetY,
          'elementId': node.elementId,
          'filePath': filePath,
          'extension': node.child.extension,
          'asInline': node.asInline,
        };
      },
    );
    DocxRegistry().setFromJson<LazyImage>(
      (Map<String, dynamic> body, metadata) {
        final filePath = body['filePath'] as String? ?? '';
        return LazyImage(
          id: body['id'],
          transformOffsetX: body['transformOffsetX'] ?? 0,
          transformOffsetY: body['transformOffsetY'] ?? 0,
          elementId: body['elementId'],
          asInline: body['asInline'] ?? true,
          data: ImageData<File>(
            buffer: File(filePath),
            extension: body['extension'] ?? '.png',
            anchorConfig: metadata?['anchorConfig'] ?? AnchorConfig.inline(),
            styles: metadata?['styles'] ?? const [],
            width: metadata?['width'],
            height: metadata?['height'],
            alt: metadata?['alt'],
            name: metadata?['name'],
          ),
        );
      },
    );

    DocxRegistry().setToJson<NonVisualDrawingProperties>(
      (NonVisualDrawingProperties node) {
        return <String, dynamic>{
          'id': node.id,
          'name': node.name,
          'description': node.description,
        };
      },
    );
    DocxRegistry().setFromJson<NonVisualDrawingProperties>(
      (
        Map<String, dynamic> body,
        Map<String, dynamic>? metadata,
      ) {
        return NonVisualDrawingProperties(
          id: body['id'] ?? '',
          name: body['name'] ?? '',
          description: body['description'],
        );
      },
    );

    DocxRegistry().setToJson<NonVisualPictureDrawingProperties>(
      (NonVisualPictureDrawingProperties node) {
        return <String, dynamic>{
          'id': node.id,
        };
      },
    );
    DocxRegistry().setFromJson<NonVisualPictureDrawingProperties>(
      (Map<String, dynamic> body, metadata) {
        return NonVisualPictureDrawingProperties();
      },
    );

    DocxRegistry().setToJson<NonVisualPictureProperties>(
      (NonVisualPictureProperties node) {
        return <String, dynamic>{
          'id': node.id,
          'nonVisualDrawingProperties':
              DocxRegistry().toJson(node.nonVisualDrawingProperties),
          'nonVisualPictureDrawingProperties':
              DocxRegistry().toJson(node.nonVisualPictureDrawingProperties),
        };
      },
    );
    DocxRegistry().setFromJson<NonVisualPictureProperties>(
      (Map<String, dynamic> body, metadata) {
        return NonVisualPictureProperties(
          nonVisualDrawingProperties: body['nonVisualDrawingProperties'] != null
              ? DocxRegistry().fromJson(
                  body['nonVisualDrawingProperties'] as Map<String, dynamic>)!
              : NonVisualDrawingProperties(id: '0', name: ''),
          nonVisualPictureDrawingProperties:
              body['nonVisualPictureDrawingProperties'] != null
                  ? DocxRegistry().fromJson(
                      body['nonVisualPictureDrawingProperties']
                          as Map<String, dynamic>)!
                  : NonVisualPictureDrawingProperties(),
        );
      },
    );

    DocxRegistry().setToJson<FillRectangle>(
      (FillRectangle node) {
        return <String, dynamic>{
          'id': node.id,
        };
      },
    );
    DocxRegistry().setFromJson<FillRectangle>(
      (Map<String, dynamic> body, metadata) {
        return FillRectangle();
      },
    );

    DocxRegistry().setToJson<AnnotationExtents>(
      (AnnotationExtents node) {
        return <String, dynamic>{
          'id': node.id,
          'cx': node.cx,
          'cy': node.cy,
        };
      },
    );
    DocxRegistry().setFromJson<AnnotationExtents>(
      (Map<String, dynamic> body, metadata) {
        return AnnotationExtents(
          cx: body['cx'] ?? 0,
          cy: body['cy'] ?? 0,
        );
      },
    );

    DocxRegistry().setToJson<Stretch>(
      (Stretch node) {
        return <String, dynamic>{
          'id': node.id,
          'child': node.child
              .map<Map<String, dynamic>>(
                  (DocxNode e) => DocxRegistry().toJson(e)!)
              .toList(),
        };
      },
    );
    DocxRegistry().setFromJson<Stretch>(
      (Map<String, dynamic> body, metadata) {
        final childList = body['child'] as List<dynamic>? ?? [];
        return Stretch(
          id: body['id'],
          child: childList
              .map<DocxNode>(
                  (e) => DocxRegistry().fromJson(e as Map<String, dynamic>)!)
              .toList(),
        );
      },
    );

    DocxRegistry().setToJson<Blip>(
      (Blip node) {
        return <String, dynamic>{
          'id': node.id,
          'child': node.child, // String embedRelId
        };
      },
    );
    DocxRegistry().setFromJson<Blip>(
      (Map<String, dynamic> body, metadata) {
        return Blip(
          id: body['id'],
          embedRelId: body['child'] as String,
        );
      },
    );

    DocxRegistry().setToJson<Picture>(
      (Picture node) {
        return <String, dynamic>{
          'id': node.id,
          'children': node.child
              .map<Map<String, dynamic>>(
                  (DocxNode e) => DocxRegistry().toJson(e)!)
              .toList(),
        };
      },
    );
    DocxRegistry().setFromJson<Picture>(
      (Map<String, dynamic> body, metadata) {
        final childrenList = body['children'] as List<dynamic>? ?? [];
        return Picture(
          id: body['id'],
          components: childrenList
              .map<DocxNode>(
                  (e) => DocxRegistry().fromJson(e as Map<String, dynamic>)!)
              .toList(),
        );
      },
    );

    DocxRegistry().setToJson<DashPattern>(
      (DashPattern node) {
        return <String, dynamic>{
          'pattern': node.pattern,
        };
      },
    );
    DocxRegistry().setFromJson<DashPattern>(
      (Map<String, dynamic> body, metadata) {
        return DashPattern(body['pattern'] as String? ?? '');
      },
    );

    DocxRegistry().setToJson<ShapeBorder>(
      (ShapeBorder node) {
        return <String, dynamic>{
          'id': node.id,
          'color': DocxRegistry().toJson(node.color),
          'width': node.width.toPt(),
          'style': node.style.index,
          'cap': node.cap.index,
          'join': node.join.index,
          'dashPattern': node.dashPattern != null
              ? DocxRegistry().toJson(node.dashPattern!)
              : null,
        };
      },
    );
    DocxRegistry().setFromJson<ShapeBorder>(
      (Map<String, dynamic> body, metadata) {
        return ShapeBorder(
          id: body['id'],
          color: DocxRegistry()
              .fromJson<Color>(body['color'] as Map<String, dynamic>)!,
          width: Point(body['width'] ?? 1),
          style: LineStyle.values[body['style'] as int? ?? 0],
          cap: LineCap.values[body['cap'] as int? ?? 0],
          join: LineJoin.values[body['join'] as int? ?? 0],
          dashPattern: body['dashPattern'] != null
              ? DocxRegistry().fromJson<DashPattern>(
                  body['dashPattern'] as Map<String, dynamic>)
              : null,
        );
      },
    );

    DocxRegistry().setToJson<Transform2D>(
      (Transform2D node) {
        return <String, dynamic>{
          'id': node.id,
          'offset': DocxRegistry().toJson(node.offset),
          'extents': DocxRegistry().toJson(node.extents),
          'rotation': node.rotation,
          'flipHorizontal': node.flipHorizontal,
          'flipVertical': node.flipVertical,
        };
      },
    );
    DocxRegistry().setFromJson<Transform2D>(
      (Map<String, dynamic> body, metadata) {
        return Transform2D(
          id: body['id'],
          offset: DocxRegistry()
              .fromJson<Offset>(body['offset'] as Map<String, dynamic>)!,
          extents: DocxRegistry().fromJson<AnnotationExtents>(
              body['extents'] as Map<String, dynamic>)!,
          rotation: body['rotation'] as int? ?? 0,
          flipHorizontal: body['flipHorizontal'] as bool? ?? false,
          flipVertical: body['flipVertical'] as bool? ?? false,
        );
      },
    );

    DocxRegistry().setToJson<TextDistance>(
      (TextDistance node) {
        return <String, dynamic>{
          'left': node.left,
          'right': node.right,
          'top': node.top,
          'bottom': node.bottom,
        };
      },
    );
    DocxRegistry().setFromJson<TextDistance>(
      (Map<String, dynamic> body, metadata) {
        return TextDistance(
          left: body['left'] as int? ?? 0,
          right: body['right'] as int? ?? 0,
          top: body['top'] as int? ?? 0,
          bottom: body['bottom'] as int? ?? 0,
        );
      },
    );

    DocxRegistry().setToJson<Drawing>(
      (Drawing node) {
        return <String, dynamic>{
          'id': node.id,
          'child': DocxRegistry().toJson(node.child),
        };
      },
    );
    DocxRegistry().setFromJson<Drawing>(
      (Map<String, dynamic> body, metadata) {
        return Drawing(
          id: body['id'],
          child: DocxRegistry()
              .fromJson(body['child'] as Map<String, dynamic>)!
              .cast<DocxNode<dynamic>>(),
        );
      },
    );

    DocxRegistry().setToJson<InlineGraphic>(
      (InlineGraphic node) {
        return <String, dynamic>{
          'id': node.id,
          'name': node.name,
          'width': node.width,
          'height': node.height,
          'distance': DocxRegistry().toJson(node.distance),
          'elementId': node.elementId,
          'children': node.child
              .map<Map<String, dynamic>>(
                  (DocxNode e) => DocxRegistry().toJson(e)!)
              .toList(),
        };
      },
    );
    DocxRegistry().setFromJson<InlineGraphic>(
      (Map<String, dynamic> body, metadata) {
        final childrenList = body['children'] as List<dynamic>? ?? [];
        return InlineGraphic(
          id: body['id'],
          name: body['name'] as String? ?? '',
          width: body['width'] as num? ?? 0,
          height: body['height'] as num? ?? 0,
          distance: DocxRegistry().fromJson<TextDistance>(
                  body['distance'] as Map<String, dynamic>) ??
              TextDistance(),
          elementId: body['elementId'] as int?,
          components: childrenList
              .map<DocxNode>(
                  (e) => DocxRegistry().fromJson(e as Map<String, dynamic>)!)
              .toList(),
        );
      },
    );

    DocxRegistry().setToJson<TextFrame>(
      (TextFrame node) {
        return <String, dynamic>{
          'id': node.id,
          'children': node.child
              .map<Map<String, dynamic>>(
                  (DocxNode e) => DocxRegistry().toJson(e)!)
              .toList(),
          'width': node.width,
          'height': node.height,
          'wrap': node.wrap.index,
          'vAnchor': node.vAnchor.index,
          'hAnchor': node.hAnchor.index,
          'xAlign': node.xAlign.index,
          'yAlign': node.yAlign.index,
          'offsetX': node.offsetX,
          'offsetY': node.offsetY,
          'border':
              node.border != null ? DocxRegistry().toJson(node.border!) : null,
        };
      },
    );
    DocxRegistry().setFromJson<TextFrame>(
      (Map<String, dynamic> body, metadata) {
        final childrenList = body['children'] as List<dynamic>? ?? [];
        return TextFrame(
          id: body['id'],
          data: childrenList
              .map<DocxNode>(
                  (e) => DocxRegistry().fromJson(e as Map<String, dynamic>)!)
              .toList(),
          width: body['width'] ?? 0,
          height: body['height'] ?? 0,
          wrap: FrameWrap.values[body['wrap'] as int? ?? 0],
          vAnchor: VerticalAnchorPosition.values[body['vAnchor'] as int? ?? 0],
          hAnchor:
              HorizontalAnchorPosition.values[body['hAnchor'] as int? ?? 0],
          xAlign: AnchorPosition.values[body['xAlign'] as int? ?? 0],
          yAlign: AnchorPosition.values[body['yAlign'] as int? ?? 0],
          offsetX: body['offsetX'] as int?,
          offsetY: body['offsetY'] as int?,
          border: body['border'] != null
              ? DocxRegistry()
                  .fromJson<Style>(body['border'] as Map<String, dynamic>)
              : null,
        );
      },
    );

    DocxRegistry().setToJson<PageColumn>(
      (PageColumn node) {
        return <String, dynamic>{
          'id': node.id,
          'children': node.child
              .map<Map<String, dynamic>>(
                  (DocxNode e) => DocxRegistry().toJson(e)!)
              .toList(),
        };
      },
    );
    DocxRegistry().setFromJson<PageColumn>(
      (Map<String, dynamic> body, metadata) {
        final childrenList = body['children'] as List<dynamic>? ?? [];
        return PageColumn(
          id: body['id'],
          children: childrenList
              .map<DocxNode>(
                  (e) => DocxRegistry().fromJson(e as Map<String, dynamic>)!)
              .toList(),
        );
      },
    );

    DocxRegistry().setToJson<LayoutConstraints>(
      (LayoutConstraints node) {
        return <String, dynamic>{
          'id': node.id,
          'children': node.child
              .map<Map<String, dynamic>>(
                  (DocxNode e) => DocxRegistry().toJson(e)!)
              .toList(),
          'minWidth': node.minWidth?.toDxa(),
          'maxWidth': node.maxWidth?.toDxa(),
        };
      },
    );
    DocxRegistry().setFromJson<LayoutConstraints>(
      (Map<String, dynamic> body, metadata) {
        final childrenList = body['children'] as List<dynamic>? ?? [];
        return LayoutConstraints(
          id: body['id'],
          children: childrenList
              .map<DocxNode>(
                  (e) => DocxRegistry().fromJson(e as Map<String, dynamic>)!)
              .toList(),
          minWidth: body['minWidth'] != null ? Dxa(body['minWidth']) : null,
          maxWidth: body['maxWidth'] != null ? Dxa(body['maxWidth']) : null,
        );
      },
    );

    DocxRegistry().setToJson<NumberingList>(
      (NumberingList node) {
        return <String, dynamic>{
          'id': node.id,
          'refKey': node.refKey,
          'inheritFromParent': node.inheritFromParent,
          'children': node.child
              .map<Map<String, dynamic>>(
                  (DocxNode e) => DocxRegistry().toJson(e)!)
              .toList(),
        };
      },
    );
    DocxRegistry().setFromJson<NumberingList>(
      (Map<String, dynamic> body, metadata) {
        final childrenList = body['children'] as List<dynamic>? ?? [];
        return NumberingList.raw(
          id: body['id'],
          refKey: body['refKey'] as String? ?? '',
          inheritFromParent: body['inheritFromParent'] as bool? ?? false,
          children: childrenList
              .map<DocxNode>(
                  (e) => DocxRegistry().fromJson(e as Map<String, dynamic>)!)
              .toList(),
        );
      },
    );

    DocxRegistry().setToJson<Row>(
      (Row node) {
        return <String, dynamic>{
          'id': node.id,
          'width': node.width.toDxa(),
          'minHeight': node.minHeight.toDxa(),
          'spacing': node.spacing.toDxa(),
          'children': node.child
              .map<Map<String, dynamic>>(
                  (DocxNode e) => DocxRegistry().toJson(e)!)
              .toList(),
          'mainAxisAlignment': node.mainAxisAlignment?.index,
          'crossAxisAlignment': node.crossAxisAlignment?.index,
        };
      },
    );
    DocxRegistry().setFromJson<Row>(
      (Map<String, dynamic> body, metadata) {
        final childrenList = body['children'] as List<dynamic>? ?? [];
        return Row(
          id: body['id'],
          children: childrenList
              .map<DocxNode>(
                  (e) => DocxRegistry().fromJson(e as Map<String, dynamic>)!)
              .toList(),
          width: Dxa(body['width'] ?? 0),
          minHeight: Dxa(body['minHeight'] ?? -1),
          spacing: Dxa(body['spacing'] ?? 0),
          mainAxisAlignment: body['mainAxisAlignment'] != null
              ? MainAxisAlignment.values[body['mainAxisAlignment'] as int]
              : null,
          crossAxisAlignment: body['crossAxisAlignment'] != null
              ? CrossAxisAlignment.values[body['crossAxisAlignment'] as int]
              : null,
        );
      },
    );

    DocxRegistry().setToJson<Section>(
      (Section node) {
        return <String, dynamic>{
          'id': node.id,
          'layout': node.layout,
          'children': node.child
              .map<Map<String, dynamic>>(
                (DocxNode e) => DocxRegistry().toJson(e)!,
              )
              .toList(),
        };
      },
    );
    DocxRegistry().setFromJson<Section>(
      (Map<String, dynamic> body, metadata) {
        final childrenList = body['children'] as List<dynamic>? ?? [];
        return Section(
          id: body['id'],
          layout: body['layout'] as DocumentLayout? ?? DocumentLayout(),
          children: childrenList
              .map<DocxNode>((e) => DocxRegistry().fromJson(
                    e as Map<String, dynamic>,
                    metadata: metadata,
                  )!)
              .toList(),
        );
      },
    );

    DocxRegistry().setToJson<HyperlinkTextPart>(
      (HyperlinkTextPart node) {
        return <String, dynamic>{
          'text': node.text,
          'hyperlink': node.hyperlink,
          'styles': node.styles.map<Map<String, dynamic>>((Object s) {
            if (s is Style) return DocxRegistry().toJson(s)!;
            return <String, dynamic>{};
          }).toList(),
        };
      },
    );
    DocxRegistry().setFromJson<HyperlinkTextPart>(
      (Map<String, dynamic> body, metadata) {
        final stylesList = body['styles'] as List<dynamic>? ?? [];
        return HyperlinkTextPart(
          text: body['text'] as String? ?? '',
          hyperlink: body['hyperlink'] as String? ?? '',
          styles: stylesList
              .map<Style>((s) =>
                  DocxRegistry().fromJson<Style>(s as Map<String, dynamic>)!)
              .toList(),
        );
      },
    );

    DocxRegistry().setToJson<HyperlinkRun>(
      (HyperlinkRun node) {
        return <String, dynamic>{
          'id': node.id,
          'child': DocxRegistry().toJson(node.child),
        };
      },
    );
    DocxRegistry().setFromJson<HyperlinkRun>(
      (Map<String, dynamic> body, metadata) {
        return HyperlinkRun(
          id: body['id'],
          child: DocxRegistry().fromJson<HyperlinkTextPart>(
              body['child'] as Map<String, dynamic>)!,
        );
      },
    );

    DocxRegistry().setToJson<NonVisualShapeProperties>(
      (NonVisualShapeProperties node) {
        return <String, dynamic>{
          'id': node.id,
          'name': node.name,
          'description': node.description,
          'shapeLocks': node.shapeLocks,
        };
      },
    );
    DocxRegistry().setFromJson<NonVisualShapeProperties>(
      (Map<String, dynamic> body, metadata) {
        return NonVisualShapeProperties(
          id: body['id'],
          name: body['name'] as String? ?? '',
          description: body['description'] as String? ?? '',
          shapeLocks: body['shapeLocks'] as bool? ?? true,
        );
      },
    );

    DocxRegistry().setToJson<AdjustValue>(
      (AdjustValue node) {
        return <String, dynamic>{
          'name': node.name,
          'value': node.value,
        };
      },
    );
    DocxRegistry().setFromJson<AdjustValue>(
      (Map<String, dynamic> body, metadata) {
        return AdjustValue(
          name: body['name'] as String? ?? '',
          value: body['value'],
        );
      },
    );

    DocxRegistry().setToJson<AdjustValueList>(
      (AdjustValueList node) {
        return <String, dynamic>{
          'id': node.id,
          'values': node.child
              .map<Map<String, dynamic>>(
                  (AdjustValue e) => DocxRegistry().toJson(e)!)
              .toList(),
        };
      },
    );
    DocxRegistry().setFromJson<AdjustValueList>(
      (Map<String, dynamic> body, metadata) {
        final valuesList = body['values'] as List<dynamic>? ?? [];
        return AdjustValueList(
          id: body['id'],
          values: valuesList
              .map<AdjustValue>((e) => DocxRegistry()
                  .fromJson<AdjustValue>(e as Map<String, dynamic>)!)
              .toList(),
        );
      },
    );

    DocxRegistry().setToJson<GeometryGuide>(
      (GeometryGuide node) {
        return <String, dynamic>{
          'name': node.name,
          'formula': node.formula,
        };
      },
    );
    DocxRegistry().setFromJson<GeometryGuide>(
      (Map<String, dynamic> body, metadata) {
        return GeometryGuide(
          name: body['name'] as String? ?? '',
          formula: body['formula'] as String? ?? '',
        );
      },
    );

    DocxRegistry().setToJson<GeometryGuideList>(
      (GeometryGuideList node) {
        return <String, dynamic>{
          'id': node.id,
          'values': node.child
              .map<Map<String, dynamic>>(
                  (GeometryGuide e) => DocxRegistry().toJson(e)!)
              .toList(),
        };
      },
    );
    DocxRegistry().setFromJson<GeometryGuideList>(
      (Map<String, dynamic> body, metadata) {
        final valuesList = body['values'] as List<dynamic>? ?? [];
        return GeometryGuideList(
          values: valuesList
              .map<GeometryGuide>((e) => DocxRegistry()
                  .fromJson<GeometryGuide>(e as Map<String, dynamic>)!)
              .toList(),
        );
      },
    );

    DocxRegistry().setToJson<AdjustHandle>(
      (AdjustHandle node) {
        return <String, dynamic>{
          'position': node.position,
          'minimum': node.minimum,
          'maximum': node.maximum,
        };
      },
    );
    DocxRegistry().setFromJson<AdjustHandle>(
      (Map<String, dynamic> body, metadata) {
        return AdjustHandle(
          position: body['position'] as String? ?? '',
          minimum: body['minimum'] as String?,
          maximum: body['maximum'] as String?,
        );
      },
    );

    DocxRegistry().setToJson<HandlesList>(
      (HandlesList node) {
        return <String, dynamic>{
          'id': node.id,
          'values': node.child
              .map<Map<String, dynamic>>(
                  (AdjustHandle e) => DocxRegistry().toJson(e)!)
              .toList(),
        };
      },
    );
    DocxRegistry().setFromJson<HandlesList>(
      (Map<String, dynamic> body, metadata) {
        final valuesList = body['values'] as List<dynamic>? ?? [];
        return HandlesList(
          id: body['id'],
          values: valuesList
              .map<AdjustHandle>((e) => DocxRegistry()
                  .fromJson<AdjustHandle>(e as Map<String, dynamic>)!)
              .toList(),
        );
      },
    );

    DocxRegistry().setToJson<GraphicData>(
      (GraphicData node) {
        return <String, dynamic>{
          'id': node.id,
          'uri': node.uri,
          'child': DocxRegistry().toJson(node.child),
        };
      },
    );
    DocxRegistry().setFromJson<GraphicData>(
      (Map<String, dynamic> body, metadata) {
        return GraphicData(
          id: body['id'],
          uri: body['uri'] as String? ?? '',
          child: DocxRegistry()
              .fromJson<DocxNode>(body['child'] as Map<String, dynamic>)!,
        );
      },
    );

    DocxRegistry().setToJson<Graphic>(
      (Graphic node) {
        return <String, dynamic>{
          'id': node.id,
          'child': DocxRegistry().toJson(node.child),
        };
      },
    );
    DocxRegistry().setFromJson<Graphic>(
      (Map<String, dynamic> body, metadata) {
        return Graphic(
          id: body['id'],
          child: DocxRegistry()
              .fromJson<GraphicData>(body['child'] as Map<String, dynamic>)!,
        );
      },
    );

    DocxRegistry().setToJson<PresetGeometry>(
      (PresetGeometry node) {
        return <String, dynamic>{
          'id': node.id,
          'preset': node.preset.index,
          'data': node.child
              .map<Map<String, dynamic>>(
                  (DocxNode e) => DocxRegistry().toJson(e)!)
              .toList(),
        };
      },
    );
    DocxRegistry().setFromJson<PresetGeometry>(
      (Map<String, dynamic> body, metadata) {
        final dataList = body['data'] as List<dynamic>? ?? [];
        return PresetGeometry(
          id: body['id'],
          preset: PresetShapeType.values[body['preset'] as int? ?? 0],
          data: dataList
              .map<DocxNode>((e) =>
                  DocxRegistry().fromJson<DocxNode>(e as Map<String, dynamic>)!)
              .toList(),
        );
      },
    );

    DocxRegistry().setToJson<GlowEffect>(
      (GlowEffect node) {
        return <String, dynamic>{
          'color': DocxRegistry().toJson(node.color),
          'radius': node.radius,
          'transparency': node.transparency,
        };
      },
    );
    DocxRegistry().setFromJson<GlowEffect>(
      (Map<String, dynamic> body, metadata) {
        return GlowEffect(
          color: DocxRegistry()
              .fromJson<Color>(body['color'] as Map<String, dynamic>)!,
          radius: body['radius'] as int? ?? 38100,
          transparency: body['transparency'] as int? ?? 0,
        );
      },
    );

    DocxRegistry().setToJson<ReflectionEffect>(
      (ReflectionEffect node) {
        return <String, dynamic>{
          'alignment': node.alignment.index,
          'blurRadius': node.blurRadius,
          'distance': node.distance,
          'direction': node.direction,
          'fadeDirection': node.fadeDirection,
          'startPosition': node.startPosition,
          'endPosition': node.endPosition,
          'startOpacity': node.startOpacity,
          'endOpacity': node.endOpacity,
        };
      },
    );
    DocxRegistry().setFromJson<ReflectionEffect>(
      (Map<String, dynamic> body, metadata) {
        return ReflectionEffect.raw(
          alignment: BorderAlignment.values[body['alignment'] as int? ?? 0],
          blurRadius: body['blurRadius'] as int? ?? 0,
          distance: body['distance'] as int? ?? 0,
          direction: body['direction'] as int? ?? 0,
          fadeDirection: body['fadeDirection'] as int? ?? 0,
          startPosition: body['startPosition'] as int? ?? 0,
          endPosition: body['endPosition'] as int? ?? 0,
          startOpacity: body['startOpacity'] as int? ?? 0,
          endOpacity: body['endOpacity'] as int? ?? 0,
        );
      },
    );

    DocxRegistry().setToJson<SoftEdgeEffect>(
      (SoftEdgeEffect node) {
        return <String, dynamic>{
          'radius': node.radius,
        };
      },
    );
    DocxRegistry().setFromJson<SoftEdgeEffect>(
      (Map<String, dynamic> body, metadata) {
        return SoftEdgeEffect(
          radius: body['radius'] as int? ?? 0,
        );
      },
    );

    DocxRegistry().setToJson<Bevel>(
      (Bevel node) {
        return <String, dynamic>{
          'width': node.width,
          'height': node.height,
          'preset': node.preset.index,
        };
      },
    );
    DocxRegistry().setFromJson<Bevel>(
      (Map<String, dynamic> body, metadata) {
        return Bevel(
          width: body['width'] as int? ?? 0,
          height: body['height'] as int? ?? 0,
          preset: BevelPreset.values[body['preset'] as int? ?? 0],
        );
      },
    );

    DocxRegistry().setToJson<Dimensional3DData>(
      (Dimensional3DData node) {
        return <String, dynamic>{
          'extrusionHeight': node.extrusionHeight,
          'extrusionColor': node.extrusionColor != null
              ? DocxRegistry().toJson(node.extrusionColor!)
              : null,
          'contourWidth': node.contourWidth,
          'contourColor': node.contourColor != null
              ? DocxRegistry().toJson(node.contourColor!)
              : null,
          'material': node.material.index,
          'topBevel': node.topBevel != null
              ? DocxRegistry().toJson(node.topBevel!)
              : null,
          'bottomBevel': node.bottomBevel != null
              ? DocxRegistry().toJson(node.bottomBevel!)
              : null,
          'lightingAngle': node.lightingAngle,
          'lightingIntensity': node.lightingIntensity,
        };
      },
    );
    DocxRegistry().setFromJson<Dimensional3DData>(
      (Map<String, dynamic> body, metadata) {
        return Dimensional3DData(
          extrusionHeight:
              (body['extrusionHeight'] as num?)?.toDouble() ?? 10.0,
          extrusionColor: body['extrusionColor'] != null
              ? DocxRegistry().fromJson<Color>(
                  body['extrusionColor'] as Map<String, dynamic>)
              : null,
          contourWidth: (body['contourWidth'] as num?)?.toDouble() ?? 1.0,
          contourColor: body['contourColor'] != null
              ? DocxRegistry()
                  .fromJson<Color>(body['contourColor'] as Map<String, dynamic>)
              : null,
          material: PresetMaterial.values[body['material'] as int? ?? 0],
          topBevel: body['topBevel'] != null
              ? DocxRegistry()
                  .fromJson<Bevel>(body['topBevel'] as Map<String, dynamic>)
              : null,
          bottomBevel: body['bottomBevel'] != null
              ? DocxRegistry()
                  .fromJson<Bevel>(body['bottomBevel'] as Map<String, dynamic>)
              : null,
          lightingAngle: (body['lightingAngle'] as num?)?.toDouble() ?? 45.0,
          lightingIntensity:
              (body['lightingIntensity'] as num?)?.toDouble() ?? 0.8,
        );
      },
    );

    DocxRegistry().setToJson<GlowEffectComponent>(
      (GlowEffectComponent node) {
        return <String, dynamic>{
          'id': node.id,
          'child': DocxRegistry().toJson(node.child),
        };
      },
    );
    DocxRegistry().setFromJson<GlowEffectComponent>(
      (Map<String, dynamic> body, metadata) {
        return GlowEffectComponent(
          id: body['id'],
          child: DocxRegistry()
              .fromJson<GlowEffect>(body['child'] as Map<String, dynamic>)!,
        );
      },
    );

    DocxRegistry().setToJson<ReflectionEffectComponent>(
      (ReflectionEffectComponent node) {
        return <String, dynamic>{
          'id': node.id,
          'child': DocxRegistry().toJson(node.child),
        };
      },
    );
    DocxRegistry().setFromJson<ReflectionEffectComponent>(
      (Map<String, dynamic> body, metadata) {
        return ReflectionEffectComponent(
          child: DocxRegistry().fromJson<ReflectionEffect>(
              body['child'] as Map<String, dynamic>)!,
        );
      },
    );

    DocxRegistry().setToJson<SoftEdgeEffectComponent>(
      (SoftEdgeEffectComponent node) {
        return <String, dynamic>{
          'id': node.id,
          'child': DocxRegistry().toJson(node.child),
        };
      },
    );
    DocxRegistry().setFromJson<SoftEdgeEffectComponent>(
      (Map<String, dynamic> body, metadata) {
        return SoftEdgeEffectComponent(
          child: DocxRegistry()
              .fromJson<SoftEdgeEffect>(body['child'] as Map<String, dynamic>)!,
        );
      },
    );

    DocxRegistry().setToJson<ShadowEffect>(
      (ShadowEffect node) {
        return <String, dynamic>{
          'id': node.id,
          'child': DocxRegistry().toJson(node.child),
        };
      },
    );
    DocxRegistry().setFromJson<ShadowEffect>(
      (Map<String, dynamic> body, metadata) {
        return ShadowEffect(
          child: DocxRegistry().fromJson<ShadowEffectData>(
              body['child'] as Map<String, dynamic>)!,
        );
      },
    );

    DocxRegistry().setToJson<Dimensional3DEffect>(
      (Dimensional3DEffect node) {
        return <String, dynamic>{
          'id': node.id,
          'child': DocxRegistry().toJson(node.child),
        };
      },
    );
    DocxRegistry().setFromJson<Dimensional3DEffect>(
      (Map<String, dynamic> body, metadata) {
        return Dimensional3DEffect(
          child: DocxRegistry().fromJson<Dimensional3DData>(
              body['child'] as Map<String, dynamic>)!,
        );
      },
    );

    DocxRegistry().setToJson<PatternFill>(
      (PatternFill node) {
        return <String, dynamic>{
          'type': node.type.index,
          'foregroundColor': node.foregroundColor != null
              ? DocxRegistry().toJson(node.foregroundColor!)
              : null,
          'backgroundColor': node.backgroundColor != null
              ? DocxRegistry().toJson(node.backgroundColor!)
              : null,
        };
      },
    );
    DocxRegistry().setFromJson<PatternFill>(
      (Map<String, dynamic> body, metadata) {
        return PatternFill(
          type: PatternType.values[body['type'] as int? ?? 0],
          foregroundColor: body['foregroundColor'] != null
              ? DocxRegistry().fromJson<Color>(
                  body['foregroundColor'] as Map<String, dynamic>)
              : null,
          backgroundColor: body['backgroundColor'] != null
              ? DocxRegistry().fromJson<Color>(
                  body['backgroundColor'] as Map<String, dynamic>)
              : null,
        );
      },
    );

    DocxRegistry().setToJson<PatternFillComponent>(
      (PatternFillComponent node) {
        return <String, dynamic>{
          'id': node.id,
          'child': DocxRegistry().toJson(node.child),
        };
      },
    );
    DocxRegistry().setFromJson<PatternFillComponent>(
      (Map<String, dynamic> body, metadata) {
        return PatternFillComponent(
          child: DocxRegistry()
              .fromJson<PatternFill>(body['child'] as Map<String, dynamic>)!,
        );
      },
    );

    DocxRegistry().setToJson<NoFillComponent>(
      (NoFillComponent node) {
        return <String, dynamic>{
          'id': node.id,
        };
      },
    );
    DocxRegistry().setFromJson<NoFillComponent>(
      (Map<String, dynamic> body, metadata) {
        return NoFillComponent();
      },
    );

    DocxRegistry().setToJson<ShapePath>(
      (ShapePath node) {
        return <String, dynamic>{
          'width': node.width,
          'height': node.height,
          'fill': node.fill.index,
          'stroke': node.stroke,
        };
      },
    );
    DocxRegistry().setFromJson<ShapePath>(
      (Map<String, dynamic> body, metadata) {
        return ShapePath(
          //TODO: we need to make commands
          // force an implementation of to/from  json
          // internally since them are too abstract
          commands: const <PathCommand>[],
          width: body['width'] as int? ?? 0,
          height: body['height'] as int? ?? 0,
          fill: PathFill.values[body['fill'] as int? ?? 0],
          stroke: body['stroke'] as bool? ?? false,
        );
      },
    );

    DocxRegistry().setToJson<ConnectionPoint>(
      (ConnectionPoint node) {
        return <String, dynamic>{
          'id': node.id,
          'x': node.x,
          'y': node.y,
        };
      },
    );
    DocxRegistry().setFromJson<ConnectionPoint>(
      (Map<String, dynamic> body, metadata) {
        return ConnectionPoint(
          id: body['id'] as int? ?? 0,
          x: body['x'] as int? ?? 0,
          y: body['y'] as int? ?? 0,
        );
      },
    );

    DocxRegistry().setToJson<CustomGeometryComponent>(
      (CustomGeometryComponent node) {
        return <String, dynamic>{
          'id': node.id,
          'paths': node.paths
              .map<Map<String, dynamic>>(
                  (ShapePath e) => DocxRegistry().toJson(e)!)
              .toList(),
          'boundingBox': <String, dynamic>{
            'left': node.boundingBox.left,
            'top': node.boundingBox.top,
            'right': node.boundingBox.right,
            'bottom': node.boundingBox.bottom
          },
          'adjustValue': DocxRegistry().toJson(node.adjustValue),
          'guide': DocxRegistry().toJson(node.guide),
          'handle': DocxRegistry().toJson(node.handle),
          'connectionPoints': node.connectionPoints
              .map<Map<String, dynamic>>(
                  (ConnectionPoint e) => DocxRegistry().toJson(e)!)
              .toList(),
        };
      },
    );
    DocxRegistry().setFromJson<CustomGeometryComponent>(
      (Map<String, dynamic> body, metadata) {
        final pathsList = body['paths'] as List<dynamic>? ?? [];
        final bbox = body['boundingBox'] as Map<String, dynamic>? ?? {};
        final connList = body['connectionPoints'] as List<dynamic>? ?? [];
        return CustomGeometryComponent(
          id: body['id'],
          paths: pathsList
              .map<ShapePath>((e) => DocxRegistry()
                  .fromJson<ShapePath>(e as Map<String, dynamic>)!)
              .toList(),
          boundingBox: Rect(
            (bbox['left'] as num?)?.toInt() ?? 0,
            (bbox['top'] as num?)?.toInt() ?? 0,
            (bbox['right'] as num?)?.toInt() ?? 0,
            (bbox['bottom'] as num?)?.toInt() ?? 0,
          ),
          adjustValue: DocxRegistry().fromJson<AdjustValueList>(
              body['adjustValue'] as Map<String, dynamic>)!,
          guide: DocxRegistry().fromJson<GeometryGuideList>(
              body['guide'] as Map<String, dynamic>)!,
          handle: DocxRegistry()
              .fromJson<HandlesList>(body['handle'] as Map<String, dynamic>)!,
          connectionPoints: connList
              .map<ConnectionPoint>((e) => DocxRegistry()
                  .fromJson<ConnectionPoint>(e as Map<String, dynamic>)!)
              .toList(),
        );
      },
    );

    DocxRegistry().setToJson<BlipFill>(
      (BlipFill node) {
        return <String, dynamic>{
          'id': node.id,
          'name': node.name,
          'blip': DocxRegistry().toJson(node.blip),
          'stretch': DocxRegistry().toJson(node.stretch),
        };
      },
    );
    DocxRegistry().setFromJson<BlipFill>(
      (Map<String, dynamic> body, metadata) {
        return BlipFill(
          id: body['id'],
          name: body['name'] as String? ?? 'pic',
          blip: DocxRegistry()
              .fromJson<Blip>(body['blip'] as Map<String, dynamic>)!,
          stretch: DocxRegistry()
              .fromJson<Stretch>(body['stretch'] as Map<String, dynamic>)!,
        );
      },
    );

    DocxRegistry().setToJson<PictureShapeProperties>(
      (PictureShapeProperties node) {
        return <String, dynamic>{
          'id': node.id,
          'transform2D': DocxRegistry().toJson(node.transform2D),
          'presetGeometry': DocxRegistry().toJson(node.presetGeometry),
        };
      },
    );
    DocxRegistry().setFromJson<PictureShapeProperties>(
      (Map<String, dynamic> body, metadata) {
        return PictureShapeProperties(
          id: body['id'],
          transform2D: DocxRegistry().fromJson<Transform2D>(
              body['transform2D'] as Map<String, dynamic>)!,
          presetGeometry: DocxRegistry().fromJson<PresetGeometry>(
              body['presetGeometry'] as Map<String, dynamic>)!,
        );
      },
    );

    DocxRegistry().setToJson<ShapeTextBoxData>(
      (ShapeTextBoxData node) {
        return <String, dynamic>{
          'content': node.content
              .map<Map<String, dynamic>>(
                  (DocxNode e) => DocxRegistry().toJson(e)!)
              .toList(),
          'margin': <String, dynamic>{
            'left': node.margin.left?.toTwips(),
            'top': node.margin.top?.toTwips(),
            'right': node.margin.right?.toTwips(),
            'bottom': node.margin.bottom?.toTwips(),
          },
          'wrapping': node.wrapping.index,
          'verticalAlignment': node.verticalAlignment.index,
          'horizontalAlignment': node.horizontalAlignment.index,
        };
      },
    );
    DocxRegistry().setFromJson<ShapeTextBoxData>(
      (Map<String, dynamic> body, metadata) {
        final contentList = body['content'] as List<dynamic>? ?? [];
        final marginMap = body['margin'] as Map<String, dynamic>? ?? {};
        return ShapeTextBoxData(
          content: contentList
              .map<DocxNode>((e) =>
                  DocxRegistry().fromJson<DocxNode>(e as Map<String, dynamic>)!)
              .toList(),
          margin: EdgeInsets(
            left: (marginMap['left'] as num?) != null
                ? Twip((marginMap['left'] as num).toInt())
                : null,
            top: (marginMap['top'] as num?) != null
                ? Twip((marginMap['top'] as num).toInt())
                : null,
            right: (marginMap['right'] as num?) != null
                ? Twip((marginMap['right'] as num).toInt())
                : null,
            bottom: (marginMap['bottom'] as num?) != null
                ? Twip((marginMap['bottom'] as num).toInt())
                : null,
          ),
          wrapping: WrapType.values[body['wrapping'] as int? ?? 0],
          verticalAlignment:
              VerticalAlignment.values[body['verticalAlignment'] as int? ?? 0],
          horizontalAlignment:
              Alignment.values[body['horizontalAlignment'] as int? ?? 0],
        );
      },
    );

    DocxRegistry().setToJson<ShapeTextBox>(
      (ShapeTextBox node) {
        return <String, dynamic>{
          'id': node.id,
          'child': DocxRegistry().toJson(node.child),
        };
      },
    );
    DocxRegistry().setFromJson<ShapeTextBox>(
      (Map<String, dynamic> body, metadata) {
        return ShapeTextBox(
          id: body['id'],
          child: DocxRegistry().fromJson<ShapeTextBoxData>(
              body['child'] as Map<String, dynamic>)!,
        );
      },
    );

    DocxRegistry().setToJson<ShapeProperties>(
      (ShapeProperties node) {
        return <String, dynamic>{
          'id': node.id,
          'transform': DocxRegistry().toJson(node.transform),
          'geometryComponent': DocxRegistry().toJson(node.geometryComponent),
          'fill': node.fill != null ? DocxRegistry().toJson(node.fill!) : null,
          'border':
              node.border != null ? DocxRegistry().toJson(node.border!) : null,
          'effects': node.effects != null
              ? DocxRegistry().toJson(node.effects!)
              : null,
        };
      },
    );
    DocxRegistry().setFromJson<ShapeProperties>(
      (Map<String, dynamic> body, metadata) {
        return ShapeProperties(
          id: body['id'],
          transform: DocxRegistry().fromJson<Transform2D>(
              body['transform'] as Map<String, dynamic>)!,
          geometryComponent: DocxRegistry().fromJson<Geometry<dynamic>>(
                  body['geometryComponent'] as Map<String, dynamic>)
              as Geometry<dynamic>,
          fill: body['fill'] != null
              ? DocxRegistry()
                  .fromJson<Fill<dynamic>>(body['fill'] as Map<String, dynamic>)
              : null,
          border: body['border'] != null
              ? DocxRegistry().fromJson<DocxNode<dynamic>>(
                  body['border'] as Map<String, dynamic>)
              : null,
          effects: body['effects'] != null
              ? DocxRegistry().fromJson<Effect<dynamic>>(
                  body['effects'] as Map<String, dynamic>)
              : null,
        );
      },
    );

    DocxRegistry().setToJson<WPShape>(
      (WPShape node) {
        return <String, dynamic>{
          'id': node.id,
          'name': node.name,
          'description': node.description,
          'shapeLocks': node.shapeLocks,
          'child': DocxRegistry().toJson(node.shapeProperties),
          'textBox': node.textBox != null
              ? DocxRegistry().toJson(node.textBox!)
              : null,
        };
      },
    );
    DocxRegistry().setFromJson<WPShape>(
      (Map<String, dynamic> body, metadata) {
        return WPShape(
          id: body['id'],
          name: body['name'] as String? ?? 'unnamed-shape',
          description: body['description'] as String? ?? '',
          shapeLocks: body['shapeLocks'] as bool? ?? true,
          shapeProperties: DocxRegistry().fromJson<ShapeProperties>(
              body['child'] as Map<String, dynamic>)!,
          textBox: body['textBox'] != null
              ? DocxRegistry().fromJson<ShapeTextBox>(
                  body['textBox'] as Map<String, dynamic>)
              : null,
        );
      },
    );
  }
}
