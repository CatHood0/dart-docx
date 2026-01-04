import 'dart:typed_data';

import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/string_ext.dart';
import '../../../core/normalizer/auto_size_normalizer.dart';

class Image extends DocxTreeNode<ImageData<Uint8List>> {
  Image({
    required super.data,
    super.parent,
    super.id,
    this.asInline = false,
    this.transformOffsetX = 0,
    this.transformOffsetY = 0,
  });

  bool asInline;
  final int transformOffsetX;
  final int transformOffsetY;

  @override
  Image get copy {
    return Image(
      id: id,
      data: ImageData<Uint8List>(
        buffer: data.buffer,
        extension: data.extension,
        styles: data.styles,
        width: data.width,
        anchorConfig: data.anchorConfig,
        height: data.height,
        name: data.name,
        alt: data.alt,
        unit: data.unit,
      ),
      transformOffsetX: transformOffsetX,
      transformOffsetY: transformOffsetY,
    );
  }

  String get getImageName => data.name ?? '';

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final String imageName = getImageName;
    if (imageName.isEmpty) {
      throw Exception(
        'The image "${data.name}" couldn\'t be '
        'founded into the DocxComponentContext',
      );
    }

    final String? relationshipId = context.store.getRelationshipIdForRef(id) ??
        context.store.getRelationshipIdForRef(rId ?? '-1');

    // the index of this image. Literally the
    // relationship id but formatted to a digit
    final int? indexId = context.store.getIndexId(id);
    if (relationshipId == null || indexId == null) {
      throw Exception('Image($id) with "$data", was not inserted in '
          'document.xml.rels, and cannot found relation id');
    }

    num? imgWidthEmu = data.width;
    num? imgHeightEmu = data.height;

    //TODO: we will need to create our own decoders for different
    // image extensions than jpeg, gif, png, webp, bmp.
    if (imgWidthEmu == null || imgHeightEmu == null) {
      final Uint8List bytes = data.buffer;
      final Size size = ImageSizeGetter.getSizeResult(MemoryInput(bytes)).size;
      // the result is a size computed in inches
      final NormalizedSizeResult resultSize =
          AutoSizeNormalizer.resizeImageBySettings(
        size,
        context.options.pageSize.toInches(),
        context.options.margins.toInches(),
        imageDpi,
      );

      imgWidthEmu ??= resultSize.width?.toEmuFromInches();
      imgHeightEmu ??= resultSize.height?.toEmuFromInches();
    }

    final Graphic graphic = Graphic(
      data: GraphicData(
        uri: 'http://schemas.openxmlformats.org/drawingml/2006/picture',
        data: Picture(
          components: <DocxTreeNode<dynamic>>[
            BlipFill(
              blip: Blip(embedRelId: relationshipId.toString()),
              stretch: Stretch(
                data: <DocxTreeNode<dynamic>>[
                  FillRectangle(),
                ],
              ),
            ),
            ShapeProperties(
              transform2D: Transform2D(
                offset: Offset(
                  x: transformOffsetX,
                  y: transformOffsetY,
                ),
                extents: AnnotationExtents(cx: imgWidthEmu!, cy: imgHeightEmu!),
              ),
              presetGeometry: PresetGeometry(
                preset: 'rect',
                data: AdjustValueList(),
              ),
            ),
            NonVisualPictureProperties(
              nonVisualDrawingProperties: NonVisualDrawingProperties(
                id: indexId.toString(),
                name: imageName,
                description: data.alt ?? imageName,
              ),
              nonVisualPictureDrawingProperties:
                  NonVisualPictureDrawingProperties(),
            ),
          ],
        ),
      ),
    );

    return <XmlElement>[
      if (!asInline)
        ...graphic.buildXml(context: context)
      else
        ...Inline(
        distance: data.anchorConfig.distanceFromText,
        components: <DocxTreeNode<dynamic>>[
          // wp:extent different from Extents that creates an a:ext
          Extent(cx: imgWidthEmu, cy: imgHeightEmu),
          DocProperties(
            docPrId: indexId.toString(),
            name: imageName,
            description: data.alt ?? imageName,
          ),
          graphic,
        ]).buildXml(context: context),
    ];
  }

  @override
  List<XmlAttribute> buildXmlStyle({required DocumentContext context}) {
    return [];
  }

  @override
  String toString() {
    return 'Image(id: $id, data: $data)';
  }

  @override
  Image? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<Image>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <Image>[this] : null;
  }
}

class XmlOffsetPosition extends XmlComponentBase<void> {
  XmlOffsetPosition({
    required this.relativeFrom,
    required bool x,
    this.alignment,
    this.offset,
  }) : super(
          xmlKey: x ? 'wp:positionH' : 'wp:positionV',
          value: null,
        );

  /// Reference point for positioning:
  /// - "margin": Relative to page margins
  /// - "page": Absolute page position
  /// - "column": Within text column
  /// - "character": Relative to specific character
  /// - "paragraph": Relative to paragraph bounds
  final String relativeFrom;

  /// Numeric offset in EMU units (used when no alignment specified)
  final num? offset;
  
  /// Text alignment: "left", "center", "right", "inside", "outside"
  /// (takes precedence over offset when both are provided)
  final String? alignment;

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      isSelfClosing: false,
      attributes: [
        XmlAttribute(
          'relativeFrom'.toName(),
          relativeFrom,
        ),
      ],
      children: [
        if (alignment != null && alignment!.isNotEmpty)
          XmlElement.tag(
            'wp:align',
            children: [
              XmlText(alignment!),
            ],
          )
        else
          XmlElement.tag(
            'wp:posOffset',
            children: [
              XmlText(offset!.toString()),
            ],
          ),
      ],
    );
  }
}
