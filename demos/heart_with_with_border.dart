import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

/// Simple demo that generates a basic document with a centered heart
/// with some effects
Future<void> main() async {
  final File outFile = File('test_resources/heart_shape_with_border.docx');
  final int size = 200.ptToEmu();

  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.standard(
      title: 'My Heart Shape Document',
      styles: DocumentStylesSheet.base(),
    ),
    root: DocumentRoot(
      sections: <DocxTreeNode<dynamic>>[
        Paragraph(
          data: <RunBase<dynamic>>[
            Run(
              wrapInRunMark: true,
              component: DrawingML(
                data: Anchor(
                  widthEmu: size,
                  heightEmu: size,
                  name: 'heart shape',
                  config: AnchorConfig.square().copyWith(
                    horizontalAnchor: HorizontalAnchorPosition.page,
                    verticalAnchor: VerticalAnchorPosition.page,
                    horizontalPosition: AnchorPosition.center,
                    verticalPosition: AnchorPosition.center,
                  ),
                  component: Graphic(
                    data: GraphicData(
                      uri: namespaces['pic']!,
                      data: WordprocessingShape(
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
                            data: Color.rgb(0xFF0000),
                          ),
                          outline: ShapeOutline(
                            width: 2.ptToEmu(),
                            color: Color.rgb(0x660000),
                          ),
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

  final Uint8List? bytes = await DocxMetadataPacker()
      .dynamicFontSearch(true)
      .bytes(doc, applyCustomTheme: false);

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  }
}
