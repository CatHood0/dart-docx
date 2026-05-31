import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

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
      StyleBuilder.paragraph('ShapeDescription')
          .name('Shape Description')
          .fontSize(Point(20))
          .fontFamily('Calibri')
          .alignment(Alignment.center)
          .build(),
      StyleBuilder.paragraph('ShapeLabel')
          .name('Shape Label')
          .fontSize(Point(16))
          .fontFamily('Calibri')
          .bold()
          .alignment(Alignment.center)
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
    return RootBody(
      sections: <DocxNode<dynamic>>[
        // Document title
        Paragraph.text(
          text: 'Custom Geometry Shapes Gallery',
          styles: <Style>[Style.ref('CustomShapeTitle')],
        ),
        Paragraph.text(
          text:
              'This demo showcases custom shapes created with path commands: MoveTo, LineTo, CubicBezTo, ArcTo, and ClosePath.',
          styles: <Style>[Style.ref('ShapeDescription')],
        ),

        Run.lineBreak().paragraph(),
        Run.lineBreak().paragraph(),

        // Example 1: Triangle shape
        ShapeExample(
          title: '1. Triangle Shape',
          description: 'Created with MoveToCommand and LineToCommand',
          shapePath: ShapePath(
            commands: <PathCommand>[
              MoveToCommand(Point(20), Point(0)),
              LineToCommand(Point(40), Point(40)),
              LineToCommand(Point(0), Point(40)),
              ClosePathCommand(),
            ],
            fill: PathFill.normal,
            stroke: true,
          ),
          fillColor: Color(0xFF4169E1),
          borderColor: Color(0xFF1E3A5F),
          borderWidth: 2,
        ),

        // Example 2: Pentagon shape
        ShapeExample(
          title: '2. Pentagon Shape',
          description: 'Pentagon with 5 sides using LineToCommand',
          shapePath: ShapePath(
            commands: <PathCommand>[
              MoveToCommand(Point(20), Point(0)),
              LineToCommand(Point(38), Point(12)),
              LineToCommand(Point(32), Point(40)),
              LineToCommand(Point(8), Point(40)),
              LineToCommand(Point(2), Point(12)),
              ClosePathCommand(),
            ],
            fill: PathFill.normal,
            stroke: true,
          ),
          fillColor: Color(0xFF32CD32),
          borderColor: Color(0xFF228B22),
          borderWidth: 3,
        ),

        // Example 3: Arrow shape
        ShapeExample(
          title: '3. Arrow Shape',
          description: 'Directional arrow using LineToCommand',
          shapePath: ShapePath(
            commands: <PathCommand>[
              MoveToCommand(Point(0), Point(20)),
              LineToCommand(Point(32), Point(20)),
              LineToCommand(Point(32), Point(8)),
              LineToCommand(Point(40), Point(20)),
              LineToCommand(Point(32), Point(32)),
              LineToCommand(Point(32), Point(20)),
              ClosePathCommand(),
            ],
            fill: PathFill.normal,
            stroke: true,
          ),
          fillColor: Color(0xFFFF6347),
          borderColor: Color(0xFF8B0000),
          borderWidth: 2,
        ),

        // Example 4: Diamond shape
        ShapeExample(
          title: '4. Diamond Shape',
          description: 'Rotated square using LineToCommand',
          shapePath: ShapePath(
            commands: <PathCommand>[
              MoveToCommand(Point(20), Point(0)),
              LineToCommand(Point(40), Point(20)),
              LineToCommand(Point(20), Point(40)),
              LineToCommand(Point(0), Point(20)),
              ClosePathCommand(),
            ],
            fill: PathFill.normal,
            stroke: true,
          ),
          fillColor: Color(0xFFFFD700),
          borderColor: Color(0xFFB8860B),
          borderWidth: 2,
        ),

        // Example 5: House shape
        ShapeExample(
          title: '5. House Shape',
          description: 'House with roof using LineToCommand',
          shapePath: ShapePath(
            commands: <PathCommand>[
              MoveToCommand(Point(20), Point(0)),
              LineToCommand(Point(40), Point(14)),
              LineToCommand(Point(40), Point(40)),
              LineToCommand(Point(0), Point(40)),
              LineToCommand(Point(0), Point(14)),
              ClosePathCommand(),
            ],
            fill: PathFill.normal,
            stroke: true,
          ),
          fillColor: Color(0xFF8B4513),
          borderColor: Color(0xFF5D3A1A),
          borderWidth: 2,
        ),

        // Example 6: Cross shape
        ShapeExample(
          title: '6. Cross Shape',
          description: 'Plus/cross shape using LineToCommand',
          shapePath: ShapePath(
            commands: <PathCommand>[
              MoveToCommand(Point(14), Point(0)),
              LineToCommand(Point(26), Point(0)),
              LineToCommand(Point(26), Point(14)),
              LineToCommand(Point(40), Point(14)),
              LineToCommand(Point(40), Point(26)),
              LineToCommand(Point(26), Point(26)),
              LineToCommand(Point(26), Point(40)),
              LineToCommand(Point(14), Point(40)),
              LineToCommand(Point(14), Point(26)),
              LineToCommand(Point(0), Point(26)),
              LineToCommand(Point(0), Point(14)),
              LineToCommand(Point(14), Point(14)),
              ClosePathCommand(),
            ],
            fill: PathFill.normal,
            stroke: true,
          ),
          fillColor: Color(0xFF9370DB),
          borderColor: Color(0xFF4B0082),
          borderWidth: 2,
        ),

        // Example 7: Hexagon shape
        ShapeExample(
          title: '7. Hexagon Shape',
          description: 'Six-sided polygon using LineToCommand',
          shapePath: ShapePath(
            commands: <PathCommand>[
              MoveToCommand(Point(20), Point(0)),
              LineToCommand(Point(36), Point(10)),
              LineToCommand(Point(36), Point(30)),
              LineToCommand(Point(20), Point(40)),
              LineToCommand(Point(4), Point(30)),
              LineToCommand(Point(4), Point(10)),
              ClosePathCommand(),
            ],
            fill: PathFill.normal,
            stroke: true,
          ),
          fillColor: Color(0xFF20B2AA),
          borderColor: Color(0xFF008B8B),
          borderWidth: 3,
        ),

        // Example 8: Star shape
        ShapeExample(
          title: '8. Star Shape',
          description: 'Five-pointed star using LineToCommand',
          shapePath: ShapePath(
            commands: <PathCommand>[
              MoveToCommand(Point(20), Point(0)),
              LineToCommand(Point(25), Point(13)),
              LineToCommand(Point(38), Point(13)),
              LineToCommand(Point(29), Point(21)),
              LineToCommand(Point(32), Point(36)),
              LineToCommand(Point(20), Point(28)),
              LineToCommand(Point(8), Point(36)),
              LineToCommand(Point(11), Point(21)),
              LineToCommand(Point(2), Point(13)),
              LineToCommand(Point(15), Point(13)),
              ClosePathCommand(),
            ],
            fill: PathFill.normal,
            stroke: true,
          ),
          fillColor: Color(0xFFFFD700),
          borderColor: Color(0xFFB8860B),
          borderWidth: 2,
        ),

        Run.lineBreak().paragraph(),
        Paragraph.text(
          text: 'Custom Geometry Components Used:',
          styles: <Style>[
            StyleBuilder.paragraph('CustomShapeTitle')
                .fontSize(Point(20))
                .build(),
          ],
        ),
        Paragraph.text(
          text:
              '• ShapePath - Defines a path with commands (MoveToCommand, LineToCommand, ClosePathCommand)',
          styles: <Style>[
            StyleBuilder.paragraph('Body').fontSize(Point(10)).build()
          ],
        ),
        Paragraph.text(
          text:
              '• CustomGeometryComponent - Contains the complete geometry definition with bounding box',
          styles: <Style>[
            StyleBuilder.paragraph('Body').fontSize(Point(10)).build()
          ],
        ),
        Paragraph.text(
          text:
              '• ShapeProperties.custom() - Creates shape properties with custom geometry',
          styles: <Style>[
            StyleBuilder.paragraph('Body').fontSize(Point(10)).build()
          ],
        ),
        Paragraph.text(
          text:
              '• Anchor with Graphic.shape() - Places the shape in the document',
          styles: <Style>[
            StyleBuilder.paragraph('Body').fontSize(Point(10)).build()
          ],
        ),
      ],
    );
  }
}

class ShapeExample extends StatelessWidget {
  ShapeExample({
    required this.title,
    required this.description,
    required this.shapePath,
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
    super.key,
  });

  final String title;
  final String description;
  final ShapePath shapePath;
  final Color fillColor;
  final Color borderColor;
  final int borderWidth;

  @override
  DocxNode<dynamic> build() {
    // Create anchor to position the shape
    final Point size = Point(40);

    // Create column with centered content
    return Column(
      children: <DocxNode<dynamic>>[
        Paragraph.text(
          text: title,
          styles: <Style>[
            StyleBuilder.paragraph('ShapeLabel')
                .spacing(before: Twip(200), after: Twip(50))
                .build(),
          ],
        ),
        Anchor(
          name: title,
          width: size,
          height: size,
          // so, yeah, using toParagraphAnchorPosition instead
          // toPageAnchorPosition makes that every forms
          // behaves properly positiong themselves as we expect
          config: AnchorConfig.block().toParagraphAnchorPosition(),
          child: Graphic.shape(
            child: WPShape(
              name: title,
              description: description,
              shapeProperties: ShapeProperties.custom(
                transform:
                    Transform2D.zero(extents: AnnotationExtents.same(size)),
                geometry: CustomGeometryComponent(
                  paths: <ShapePath>[shapePath],
                  guide: GeometryGuideList(),
                  adjustValue: AdjustValueList(),
                  handle: HandlesList(),
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
        Paragraph.text(
          text: description,
          styles: <Style>[
            StyleBuilder.paragraph('Body')
                .fontSize(Point(10))
                .alignment(Alignment.center)
                .spacing(
                  after: Twip(200),
                )
                .build(),
          ],
        ),
      ],
    );
  }
}
