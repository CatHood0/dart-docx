import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

/// Simple demo that generates a basic document with a centered heart
Future<void> main() async {
  final File outFile = File('test_resources/heart_shape.docx');
  final int size = 200.toEmuFromPoints();

  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.blank(
      title: 'My Heart Shape Document',
      styles: DocumentStylesSheet.base(),
    ),
    root: DocumentRoot(
      sections: <DocxTreeNode<dynamic>>[
        Paragraph(
          data: <RunBase<dynamic>>[
            Run(
              wrapInRunMark: true,
              component: WordDrawingML(
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
                            extents: AnnotationExtents(
                              cx: size,
                              cy: size,
                            ),
                          ),
                          geometryComponent:
                              PresetGeometry(preset: PresetShapeType.heart),
                          fill: SolidFill(
                            data: Color.rgb(0xFF0000),
                          ),
                          outline: ShapeOutline(
                            width: emu,
                            color: Color.rgb(0xFF0000),
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
      .logPath(DocxPaths.documentFilePath)
      .bytes(doc, applyCustomTheme: false);

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  }
}
