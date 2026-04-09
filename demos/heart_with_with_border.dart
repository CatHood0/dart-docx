import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

Future<void> main() async {
  final File outFile = File('test_resources/heart_shape_with_border.docx');
  final int size = 200.ptToEmu();

  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.standard(
      title: 'My Heart Shape Document',
      styles: DocumentStyles.base(),
    ),
    root: DocumentRoot(
      sections: <DocxTreeNode<dynamic>>[
        Paragraph(
          children: <RunBase<dynamic>>[
            Run(
              wrapInRunMark: true,
              component: DrawingML(
                child: Anchor(
                  width: size,
                  height: size,
                  name: 'heart shape',
                  config: AnchorConfig.square().copyWith(
                    horizontalAnchor: HorizontalAnchorPosition.page,
                    verticalAnchor: VerticalAnchorPosition.page,
                    horizontalPosition: AnchorPosition.center,
                    verticalPosition: AnchorPosition.center,
                  ),
                  child: Graphic.pic(
                    child: WordprocessingShape(
                      name: 'heart shape',
                      description: 'A centered heart shape',
                      shapeLocks: true,
                      shapeProperties: ShapeProperties(
                        transform2D: Transform2D(
                          offset: Offset.zero(),
                          extents: AnnotationExtents.zero(),
                        ),
                        geometryComponent:
                            PresetGeometry(preset: PresetShapeType.heart),
                        fill: SolidFill(
                          color: Color.rgb(0xFF0000),
                        ),
                        border: ShapeBorder(
                          width: 2.ptToEmu(),
                          color: Color.rgb(0x660000),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  final Uint8List? bytes = await DocxPacker()
      .dynamicFontSearch(true)
      .execute(doc, applyCustomTheme: false);

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  }
}
