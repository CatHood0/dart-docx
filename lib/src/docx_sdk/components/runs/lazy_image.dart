import 'dart:io';

import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';

import '../../../../docx.dart';

class LazyImage extends DocxTreeNode<ImageData<File>> {
  LazyImage({
    required super.data,
    super.parent,
    super.id,
    this.asInline = false,
  });

  bool asInline;

  @override
  LazyImage get copy => LazyImage(
        id: id,
        data: ImageData<File>(
          buffer: File(data.buffer.path),
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

  String get getImageName => data.name ?? '';

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final String imageName = getImageName;
    if (imageName.isEmpty) {
      throw Exception(
        'The image "${data.name}" couldn\'t be '
        'founded into the DocxComponentContext. Media Store: ${context.store.media}',
      );
    }

    final int? numRelationshipId =
        context.store.getAssignedIdForRef(id) ??
            context.store.getAssignedIdForRef(rId!);

    if (numRelationshipId == null) {
      throw Exception('Image($id) with "$data", was not inserted in '
          'document.xml.rels, and cannot found relation id');
    }

    num? imgWidthEmu;
    num? imgHeightEmu;
    if (data.width != null) {
      imgWidthEmu = data.width!.toEmuFromUnit(data.unit);
    }
    if (data.height != null) {
      imgHeightEmu = data.height!.toEmuFromUnit(data.unit);
    }

    //TODO: we will need to create our own decoders for different
    // image extensions than jpeg, gif, png, webp, bmp.
    if (imgWidthEmu == null && imgHeightEmu == null) {
      final Size size =
          ImageSizeGetter.getSizeResult(FileInput(data.buffer)).size;
      imgWidthEmu = size.width * emuPerInch / imageDpi;
      imgHeightEmu = size.height * emuPerInch / imageDpi;
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
            docPrId: rId!,
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
  LazyImage? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<LazyImage>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <LazyImage>[this] : null;
  }
}
