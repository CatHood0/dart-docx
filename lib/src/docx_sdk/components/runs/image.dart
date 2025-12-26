import 'dart:typed_data';

import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/string_ext.dart';
import '../../../core/normalizer/auto_size_normalizer.dart';
import '../containers/anchor.dart';

class Image extends DocxTreeNode<ImageData<Uint8List>> {
  Image({
    required super.data,
    super.parent,
    super.id,
    this.asInline = false,
  });

  bool asInline;

  @override
  Image get copy {
    return Image(
      id: id,
      data: ImageData<Uint8List>(
        buffer: data.buffer,
        extension: data.extension,
        styles: data.styles,
        width: data.width,
        height: data.height,
        name: data.name,
        offsetX: data.offsetX,
        offsetY: data.offsetY,
        alt: data.alt,
        unit: data.unit,
        frameOffsetY: data.frameOffsetY,
        frameAlignY: data.frameAlignY,
        frameOffsetX: data.frameOffsetX,
        frameAlignX: data.frameAlignX,
      ),
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

    final int? numRelationshipId = context.store.getAssignedIdForRef(id) ??
        context.store.getAssignedIdForRef(rId ?? '-1');

    if (numRelationshipId == null) {
      throw Exception('Image($id) with "$data", was not inserted in '
          'document.xml.rels, and cannot found relation id');
    }

    num? imgWidthEmu = data.width;
    num? imgHeightEmu = data.height;

    //TODO: we will need to create our own decoders for different
    // image extensions than jpeg, gif, png, webp, bmp.
    if (imgWidthEmu == null && imgHeightEmu == null) {
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

      imgWidthEmu = resultSize.width?.toEmuFromInches();
      imgHeightEmu = resultSize.height?.toEmuFromInches();
    }

    final Graphic graphic = Graphic(
      data: GraphicData(
        uri: namespaces['pic']!,
        data: Picture(
          components: <DocxTreeNode<dynamic>>[
            BlipFill(
              blip: Blip(embedRelId: numRelationshipId.toString()),
              stretch: Stretch(
                data: <DocxTreeNode<dynamic>>[
                  FillRectangle(),
                ],
              ),
            ),
            ShapeProperties(
              transform2D: Transform2D(
                offset: Offset(
                  x: data.frameOffsetX ?? 0,
                  y: data.frameOffsetY ?? 0,
                ),
                extents: Extents(cx: imgWidthEmu!, cy: imgHeightEmu!),
              ),
              presetGeometry: PresetGeometry(
                preset: 'rect',
                data: AdjustValueList(),
              ),
            ),
            NonVisualPictureProperties(
              nonVisualDrawingProperties: NonVisualDrawingProperties(
                id: numRelationshipId.toString(),
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
        ...Inline(components: <DocxTreeNode<dynamic>>[
          // wp:extent different from Extents that creates an a:ext
          Extent(cx: imgWidthEmu, cy: imgHeightEmu),
          DocProperties(
            docPrId: numRelationshipId.toString(),
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
    required bool x,
    required this.alignment,
    required this.offset,
    this.relative = Anchor.relativeParagraphKey,
  }) : super(
          xmlKey: x ? 'wp:positionH' : 'wp:positionV',
          value: null,
        );
  final num offset;
  final String relative;
  final String alignment;

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      isSelfClosing: false,
      attributes: [
        XmlAttribute(
          'relativeFrom'.toName(),
          relative,
        ),
      ],
      children: [
        XmlElement.tag(
          alignment == 'center' ? 'wp:align' : 'wp:posOffset',
          children: [
            XmlText(
              alignment == 'center' ? 'center' : offset.toString(),
            ),
          ],
        ),
      ],
    );
  }
}
