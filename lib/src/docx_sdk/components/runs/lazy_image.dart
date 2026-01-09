import 'dart:io';

import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';

class LazyImage extends DocxTreeNode<ImageData<File>> {
  LazyImage({
    required super.data,
    super.parent,
    super.id,
    this.elementId,
    this.asInline = false,
    this.transformOffsetX = 0,
    this.transformOffsetY = 0,
  });

  bool asInline;
  final int transformOffsetX;
  final int transformOffsetY;
  int? elementId;

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
          alt: data.alt,
          unit: data.unit,
        ),
        transformOffsetY: transformOffsetY,
        transformOffsetX: transformOffsetX,
      );

  String get getImageName => data.name ?? '';

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final String imageName = getImageName;
    if (imageName.isEmpty) {
      throw Exception(
        'The image "${data.name}" couldn\'t be '
        'founded into the DocxComponentContext. Media Store: ${context.mediaStore.media}',
      );
    }

    final String? relationshipId =
        context.mediaStore.getRelationshipIdForRef(id) ??
            context.mediaStore.getRelationshipIdForRef(rId ?? '-1');

    elementId ??= context.drawingStore.getIdFromRef(ref: id) ??
        // usually, the element id is computed from
        // the anchor or inline parent, so, we prefer
        // using that one value, since was computed exactly for this
        // element
        context.getAncestorOfExactType<Anchor>()?.elementId?.castOrNull() ??
        context.getAncestorOfExactType<Inline>()?.elementId?.castOrNull() ??
        context.drawingStore.getNextId(id);

    if (relationshipId == null) {
      throw Exception('Image($id) with "$data", was not inserted in '
          'document.xml.rels, and cannot found relation id');
    }

    num? imgWidthEmu;
    num? imgHeightEmu;
    if (data.width != null) {
      imgWidthEmu = data.width!.unitToEmu(data.unit);
    }
    if (data.height != null) {
      imgHeightEmu = data.height!.unitToEmu(data.unit);
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
            BlipFill.pic(
              blip: Blip(embedRelId: relationshipId.toString()),
              stretch: Stretch(
                data: <DocxTreeNode<dynamic>>[
                  FillRectangle(),
                ],
              ),
            ),
            PictureShapeProperties(
              transform2D: Transform2D(
                offset: Offset(
                  x: transformOffsetX,
                  y: transformOffsetY,
                ),
                extents: AnnotationExtents(cx: imgWidthEmu!, cy: imgHeightEmu!),
              ),
              presetGeometry: PresetGeometry(preset: PresetShapeType.rectangle),
            ),
            NonVisualPictureProperties(
              nonVisualDrawingProperties: NonVisualDrawingProperties(
                id: elementId!.toString(),
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
          name: imageName,
          width: imgWidthEmu,
          height: imgHeightEmu,
          components: <DocxTreeNode<dynamic>>[graphic],
          distance: data.anchorConfig.distanceFromText,
        ).buildXml(context: context),
    ];
  }

  @override
  List<XmlAttribute> buildXmlStyle({required DocumentContext context}) {
    return [];
  }

  @override
  String toString() {
    return 'LazyImage(id: $id, data: $data)';
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
