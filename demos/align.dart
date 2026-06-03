import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

final PageSize pageSize = PageSize.letter;
final DocumentMargins margins = DocumentMargins.fromCm(
  top: 1.52,
  right: 1.52,
  left: 1.52,
  bottom: 1.52,
  header: 1.1,
  footer: 1.1,
);

final DocumentOptions options = DocumentOptions.standard(
  title: 'Minimal',
  styles: DocumentStyles.base(),
  section: DocumentLayout(
    size: pageSize,
    margins: margins,
  ),
);

Future<void> main() async {
  final File outFile = File('test_resources/align.docx');

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
  @override
  DocxNode<dynamic> build() {
    return RootBody(
      sections: <DocxNode<dynamic>>[
        Align(
          alignment: Alignment.center,
          child: Paragraph.text(
            text: 'Hello World',
            textStyle: TextStyle(headingLevel: 1),
          ),
        ),
      ],
    );
  }
}
