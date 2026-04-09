import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

Future<void> main() async {
  final File outFile = File('test_resources/heart_shape.docx');
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
                    horizontalAnchor: HorizontalAnchorPosition.paragraph,
                    verticalAnchor: VerticalAnchorPosition.paragraph,
                    horizontalPosition: AnchorPosition.left,
                    verticalPosition: AnchorPosition.left,

                  ),
                  child: Graphic.pic(
                    child: WordprocessingShape(
                      name: 'heart shape',
                      description: 'A centered heart shape',
                      shapeLocks: true,
                      shapeProperties: ShapeProperties(
                        transform2D: Transform2D(
                          offset:
                              Offset(x: 40.pixelsToEmu(), y: 50.pixelsToEmu()),
                          rotation: 90,
                          extents: AnnotationExtents(
                            cx: size,
                            cy: size,
                          ),
                        ),
                        geometryComponent:
                            PresetGeometry(preset: PresetShapeType.chevron),
                        fill: SolidFill(
                          color: Color.rgb(0xFF0000),
                        ),
                        border: ShapeBorder(
                          color: Color.rgb(0xFF0000),
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
      .logPath(DocxPaths.documentFilePath)
      .execute(doc, applyCustomTheme: false);

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  }
}
