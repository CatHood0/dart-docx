import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';
import 'package:docx/src/core/extensions/cast_ext.dart';

final PageSize pageSize = PageSize.a4;
final DocumentMargins margins = DocumentMargins.fromCm(
  top: 2.0,
  right: 2.0,
  left: 2.0,
  bottom: 2.0,
  header: 1.0,
  footer: 1.0,
);

final DocumentOptions options = DocumentOptions.standard(
  title: 'Custom Geometry Demo',
  styles: DocumentStyles.base().withNewStyles(
    <Style>[
      StyleBuilder.paragraph('CustomShapeTitle')
          .name('Custom Shape Gallery')
          .fontSize(Point(28))
          .fontFamily('Calibri')
          .bold()
          .alignment(Alignment.center)
          .qFormat(true)
          .build(),
    ],
  ),
  section: DocumentLayout(
    size: pageSize,
    margins: margins,
  ),
);

Future<void> main() async {
  final File outFile = File('test_resources/custom_geometry.docx');
  DocxElements.instance.ensureInitialized();
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
  // Create anchor to position the shape
  final Point size = Point(40);
  final String title = '1. Triangle Shape';
  final String description = 'Created with MoveToCommand and LineToCommand';
  final Color fillColor = Color(0xFF4169E1);
  final Color borderColor = Color(0xFF1E3A5F);
  final int borderWidth = 2;

  @override
  DocxNode<dynamic> build() {
    return RootBody(
      sections: <DocxNode<dynamic>>[
        Paragraph.text(
          text: 'Custom Geometry Triangle',
          styles: <Style>[Style.ref('CustomShapeTitle')],
        ),

        Anchor(
          name: title,
          width: size,
          height: size,
          config: AnchorConfig.block().toParagraphAnchorPosition(),
          child: Graphic.shape(
            child: WPShape(
              name: title,
              description: description,
              shapeProperties: ShapeProperties.custom(
                transform: Transform2D.zero(
                  extents: AnnotationExtents.same(size),
                ),
                geometry: CustomGeometryComponent.basic(
                  paths: ShapePath(
                    commands: <PathCommand>[
                      MoveToCommand(Point(20), Point(0)),
                      LineToCommand(Point(40), Point(40)),
                      LineToCommand(Point(0), Point(40)),
                      ClosePathCommand(),
                    ],
                    fill: PathFill.normal,
                    stroke: true,
                  ).toList(),
                ),
                fill: SolidFill(color: fillColor),
                border: ShapeBorder(
                  width: Point(borderWidth),
                  color: borderColor,
                ),
              ),
            ),
          ),
        ).drawing().run().paragraph(),
      ],
    );
  }
}
