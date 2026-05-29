import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

Future<void> main() async {
  final File outFile = File('test_resources/heart_shape_with_border.docx');
  final  Point size = Point(200);

  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.standard(
      title: 'My Heart Shape Document',
      styles: DocumentStyles.base(),
    ),
    root: RootBody(
      sections: <DocxNode<dynamic>>[
        Anchor(
          width: size,
          height: size,
          name: 'heart shape',
          config: AnchorConfig.square().toPageAnchorPosition(
            horizontalPosition: AnchorPosition.center,
            verticalPosition: AnchorPosition.center,
          ),
          child: Graphic.pic(
            child: WPShape(
              name: 'heart shape',
              description: 'A centered heart shape',
              shapeLocks: true,
              shapeProperties: ShapeProperties.preset(
                preset: PresetShapeType.curvedLeftRightArrow,
                fill: SolidFill(color: Color(0xFF0000)),
                border: ShapeBorder(
                  width: Point(2),
                  color: Color(0x660000),
                ),
                transform: Transform2D.zero(),
              ),
            ),
          ),
        ).drawing().run().paragraph(),
      ],
    ),
  );

  final Uint8List? bytes = await DocxPacker()
      .autoRegisterFonts(true)
      .execute(doc, applyCustomTheme: false);

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  }
}
