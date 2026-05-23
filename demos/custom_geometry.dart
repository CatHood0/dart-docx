import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

//TODO: this doesnt work
// I'm working in this yet, since
// shape properties are too weird
Future<void> main() async {
  final File outFile = File('test_resources/custom_geometry.docx');

  final PageSize pageSize = PageSize.a4;
  final DocumentMargins margins = DocumentMargins.fromCm(
    top: 2.0,
    right: 2.0,
    left: 2.0,
    bottom: 2.0,
    header: 1.0,
    footer: 1.0,
  );

  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.standard(
      title: 'Custom Geometry Demo',
      styles: DocumentStyles.base().withNewStyles(
        <Style>[
          StyleBuilder.paragraph('CustomShapeTitle')
              .name('Custom Shape Gallery')
              .fontSize(28.ptToHalfPoints())
              .fontFamily('Calibri')
              .bold()
              .alignment(Alignment.center)
              .qFormat(true)
              .build(),
          StyleBuilder.paragraph('ShapeDescription')
              .name('Shape Description')
              .fontSize(20.ptToHalfPoints())
              .fontFamily('Calibri')
              .alignment(Alignment.center)
              .build(),
          StyleBuilder.paragraph('ShapeLabel')
              .name('Shape Label')
              .fontSize(16.ptToHalfPoints())
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
    ),
    root: DocxRoot(
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

        Run.lineBreak(),
        Run.lineBreak(),

        // Example 1: Triangle shape
        _buildShapeExample(
          title: '1. Triangle Shape',
          description: 'Created with MoveToCommand and LineToCommand',
          shapePath: ShapePath(
            commands: <PathCommand>[
              MoveToCommand(250000, 0),
              LineToCommand(500000, 450000),
              LineToCommand(0, 450000),
              ClosePathCommand(),
            ],
            width: 500000,
            height: 500000,
            fill: PathFill.normal,
            stroke: true,
          ),
          fillColor: Color(0xFF4169E1),
          borderColor: Color(0xFF1E3A5F),
          borderWidth: 2,
        ),

        // Example 2: Pentagon shape
        _buildShapeExample(
          title: '2. Pentagon Shape',
          description: 'Pentagon with 5 sides using LineToCommand',
          shapePath: ShapePath(
            commands: <PathCommand>[
              MoveToCommand(250000, 0),
              LineToCommand(475000, 150000),
              LineToCommand(400000, 450000),
              LineToCommand(100000, 450000),
              LineToCommand(25000, 150000),
              ClosePathCommand(),
            ],
            width: 500000,
            height: 500000,
            fill: PathFill.normal,
            stroke: true,
          ),
          fillColor: Color(0xFF32CD32),
          borderColor: Color(0xFF228B22),
          borderWidth: 3,
        ),

        // Example 3: Arrow shape
        _buildShapeExample(
          title: '3. Arrow Shape',
          description: 'Directional arrow using LineToCommand',
          shapePath: ShapePath(
            commands: <PathCommand>[
              MoveToCommand(0, 250000),
              LineToCommand(400000, 250000),
              LineToCommand(400000, 100000),
              LineToCommand(500000, 250000),
              LineToCommand(400000, 400000),
              LineToCommand(400000, 250000),
              ClosePathCommand(),
            ],
            width: 500000,
            height: 500000,
            fill: PathFill.normal,
            stroke: true,
          ),
          fillColor: Color(0xFFFF6347),
          borderColor: Color(0xFF8B0000),
          borderWidth: 2,
        ),

        // Example 4: Diamond shape
        _buildShapeExample(
          title: '4. Diamond Shape',
          description: 'Rotated square using LineToCommand',
          shapePath: ShapePath(
            commands: <PathCommand>[
              MoveToCommand(250000, 0),
              LineToCommand(500000, 250000),
              LineToCommand(250000, 500000),
              LineToCommand(0, 250000),
              ClosePathCommand(),
            ],
            width: 500000,
            height: 500000,
            fill: PathFill.normal,
            stroke: true,
          ),
          fillColor: Color(0xFFFFD700),
          borderColor: Color(0xFFB8860B),
          borderWidth: 2,
        ),

        // Example 5: House shape
        _buildShapeExample(
          title: '5. House Shape',
          description: 'House with roof using LineToCommand',
          shapePath: ShapePath(
            commands: <PathCommand>[
              MoveToCommand(250000, 0),
              LineToCommand(500000, 180000),
              LineToCommand(500000, 500000),
              LineToCommand(0, 500000),
              LineToCommand(0, 180000),
              ClosePathCommand(),
            ],
            width: 500000,
            height: 500000,
            fill: PathFill.normal,
            stroke: true,
          ),
          fillColor: Color(0xFF8B4513),
          borderColor: Color(0xFF5D3A1A),
          borderWidth: 2,
        ),

        // Example 6: Cross shape
        _buildShapeExample(
          title: '6. Cross Shape',
          description: 'Plus/cross shape using LineToCommand',
          shapePath: ShapePath(
            commands: <PathCommand>[
              MoveToCommand(180000, 0),
              LineToCommand(320000, 0),
              LineToCommand(320000, 180000),
              LineToCommand(500000, 180000),
              LineToCommand(500000, 320000),
              LineToCommand(320000, 320000),
              LineToCommand(320000, 500000),
              LineToCommand(180000, 500000),
              LineToCommand(180000, 320000),
              LineToCommand(0, 320000),
              LineToCommand(0, 180000),
              LineToCommand(180000, 180000),
              ClosePathCommand(),
            ],
            width: 500000,
            height: 500000,
            fill: PathFill.normal,
            stroke: true,
          ),
          fillColor: Color(0xFF9370DB),
          borderColor: Color(0xFF4B0082),
          borderWidth: 2,
        ),

        // Example 7: Hexagon shape
        _buildShapeExample(
          title: '7. Hexagon Shape',
          description: 'Six-sided polygon using LineToCommand',
          shapePath: ShapePath(
            commands: <PathCommand>[
              MoveToCommand(250000, 0),
              LineToCommand(450000, 125000),
              LineToCommand(450000, 375000),
              LineToCommand(250000, 500000),
              LineToCommand(50000, 375000),
              LineToCommand(50000, 125000),
              ClosePathCommand(),
            ],
            width: 500000,
            height: 500000,
            fill: PathFill.normal,
            stroke: true,
          ),
          fillColor: Color(0xFF20B2AA),
          borderColor: Color(0xFF008B8B),
          borderWidth: 3,
        ),

        // Example 8: Star shape
        _buildShapeExample(
          title: '8. Star Shape',
          description: 'Five-pointed star using LineToCommand',
          shapePath: ShapePath(
            commands: <PathCommand>[
              MoveToCommand(250000, 0),
              LineToCommand(309000, 162000),
              LineToCommand(480000, 162000),
              LineToCommand(360000, 262000),
              LineToCommand(400000, 450000),
              LineToCommand(250000, 350000),
              LineToCommand(100000, 450000),
              LineToCommand(140000, 262000),
              LineToCommand(20000, 162000),
              LineToCommand(191000, 162000),
              ClosePathCommand(),
            ],
            width: 500000,
            height: 500000,
            fill: PathFill.normal,
            stroke: true,
          ),
          fillColor: Color(0xFFFFD700),
          borderColor: Color(0xFFB8860B),
          borderWidth: 2,
        ),

        Run.lineBreak(),
        Paragraph.text(
          text: 'Custom Geometry Components Used:',
          styles: <Style>[
            StyleBuilder.paragraph('CustomShapeTitle')
                .fontSize(20.ptToHalfPoints())
                .build(),
          ],
        ),
        Paragraph.text(
          text:
              '• ShapePath - Defines a path with commands (MoveToCommand, LineToCommand, ClosePathCommand)',
          styles: <Style>[
            StyleBuilder.paragraph('Body').fontSize(10.ptToHalfPoints()).build()
          ],
        ),
        Paragraph.text(
          text:
              '• CustomGeometryComponent - Contains the complete geometry definition with bounding box',
          styles: <Style>[
            StyleBuilder.paragraph('Body').fontSize(10.ptToHalfPoints()).build()
          ],
        ),
        Paragraph.text(
          text:
              '• ShapeProperties.custom() - Creates shape properties with custom geometry',
          styles: <Style>[
            StyleBuilder.paragraph('Body').fontSize(10.ptToHalfPoints()).build()
          ],
        ),
        Paragraph.text(
          text:
              '• Anchor with Graphic.shape() - Places the shape in the document',
          styles: <Style>[
            StyleBuilder.paragraph('Body').fontSize(10.ptToHalfPoints()).build()
          ],
        ),
      ],
    ),
  );

  final Uint8List? bytes = await DocxPacker()
      .autoRegisterFonts(true)
      .noTrimRuns()
      .normalStyleIfNeeded()
      .logPath(DocxPaths.documentFilePath)
      .execute(
        doc,
        applyCustomTheme: true,
      );

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  } else {
    stderr.writeln('Failed to generate custom_geometry.docx');
  }
}

/// Builds a shape example with title, description, and the shape itself
DocxNode<dynamic> _buildShapeExample({
  required String title,
  required String description,
  required ShapePath shapePath,
  required Color fillColor,
  required Color borderColor,
  required int borderWidth,
}) {
  // Build the custom geometry component
  final CustomGeometryComponent geometry = CustomGeometryComponent(
    paths: <ShapePath>[shapePath],
    boundingBox: Rect(0, 0, shapePath.width, shapePath.height),
    guide: GeometryGuideList(),
    adjustValue: AdjustValueList(),
    handle: HandlesList(),
  );

  // Create anchor to position the shape
  final int size = 150.ptToEmu();

  // Build shape properties with custom geometry
  final ShapeProperties shapeProperties = ShapeProperties.custom(
    transform: Transform2D.zero(extents: AnnotationExtents.same(size)),
    geometry: geometry,
    fill: SolidFill(color: fillColor),
    border: ShapeBorder(
      width: Point(borderWidth),
      color: borderColor,
    ),
  );

  // Build the wordprocessing shape
  final WPShape shape = WPShape(
    shapeProperties: shapeProperties,
    name: title,
    description: description,
  );

  // Create column with centered content
  return Column(
    children: <DocxNode<dynamic>>[
      Paragraph.text(
        text: title,
        styles: <Style>[
          StyleBuilder.paragraph('ShapeLabel')
              .spacing(before: 200, after: 50)
              .build(),
        ],
      ),
      Anchor(
        name: title,
        width: size,
        height: size,
        config: AnchorConfig.square().toPageAnchorPosition(
          horizontalPosition: AnchorPosition.center,
          verticalPosition: AnchorPosition.center,
        ),
        child: Graphic.shape(child: shape),
      ).drawing().run().paragraph(),
      Paragraph.text(
        text: description,
        styles: <Style>[
          StyleBuilder.paragraph('Body')
              .fontSize(10.ptToHalfPoints())
              .alignment(Alignment.center)
              .spacing(after: 200)
              .build(),
        ],
      ),
    ],
  );
}
