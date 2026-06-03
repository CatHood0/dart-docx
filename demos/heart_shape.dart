import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

final DocumentOptions options = DocumentOptions.standard(
  title: 'My Heart Shape Document',
  styles: DocumentStyles.base(),
);

Future<void> main() async {
  final File outFile = File('test_resources/heart_shape.docx');

  DocxElements.instance.ensureInitialized();
  DocxElements.instance.debugMode(true);
  final Uint8List? bytes = await runCompilation(
    MyApp(),
    logAll: true,
    options: options,
    checkStylReferences: true,
  );

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  }
}

class MyApp extends StatelessWidget {
  @override
  DocxNode<dynamic> build() {
    final Point size = Point(200);
    return RootBody(
      sections: <DocxNode<dynamic>>[
        Anchor(
          width: size,
          height: size,
          name: 'heart shape',
          config: AnchorConfig.watermark().toPageAnchorPosition(
            horizontalPosition: AnchorPosition.center,
            verticalPosition: AnchorPosition.center,
          ),
          child: Graphic.pic(
            child: WPShape(
              name: 'heart shape',
              description: 'A heart shape',
              shapeProperties: ShapeProperties.preset(
                preset: PresetShapeType.heart,
                fill: SolidFill(color: Color(0xFF0000)),
                transform: Transform2D.zero(
                  extents: AnnotationExtents.same(size),
                ),
              ),
            ),
          ),
        ).drawing().run().paragraph(),
      ],
    );
  }
}
