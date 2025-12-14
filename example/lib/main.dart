import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx_transformer.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart'
    hide Node, BoldAttribute, LinkAttribute, Style, StyleAttribute;
import 'package:flutter_quill/quill_delta.dart';
import 'package:path/path.dart' hide Style;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Body(),
      localizationsDelegates: [FlutterQuillLocalizations.delegate],
    );
  }
}

// ...existing main function and MyApp class...

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _DesktopTreeViewExampleState();
}

class _DesktopTreeViewExampleState extends State<Body> {
  final QuillController _controller = QuillController.basic();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _plainTextController = TextEditingController();
  final TextEditingController _markdownTextController = TextEditingController();

  final DeltaFromDocxParser parser = DeltaFromDocxParser(
    options: DeltaParserOptions(
      ignoreColorWhenNoSupported: true,
      onDetectImage: (Uint8List imageBytes, String name) async {
        final String path = (await getTemporaryDirectory()).path;
        final File file = File(join(path, name));
        if (!(await file.exists())) {
          await file.writeAsBytes(imageBytes, flush: true);
        }
        return file.path;
      },
      shouldParserSizeToHeading: (String value) {
        return null;
      },
    ),
  );

  void _loadDocxDocument() async {
    final XFile? file = await openFile(
      confirmButtonText: 'Take docx',
      acceptedTypeGroups: [
        XTypeGroup(label: 'DOCX', extensions: ['docx', 'doc']),
      ],
    );
    if (file != null) {
      final Delta? delta = await parser.build(data: await file.readAsBytes());
      if (delta != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.document = Document.fromDelta(delta);
          setState(() {});
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _plainTextController.dispose(); // Dispose new plain text controller
    _markdownTextController.dispose(); // Dispose new markdown controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Define 3 tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text(
            'Multi-Editor App',
          ), // Added a title for the app bar
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Plain Text'),
              Tab(text: 'Quill Editor'),
              Tab(text: 'Markdown'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Plain Text Editor
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _plainTextController,
                maxLines: null,
                expands: true,
                textAlignVertical:
                    TextAlignVertical.top, // Aligns text to the top
                decoration: const InputDecoration(
                  hintText: 'Start typing plain text here...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12.0),
                ),
              ),
            ),

            // Tab 2: Flutter Quill Editor
            Column(
              children: [
                // DOCX Load/Save buttons
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        onPressed: () async {
                          _loadDocxDocument();
                        },
                        child: const Text('Load DOCX'),
                      ),
                      const SizedBox(width: 16),
                      MaterialButton(
                        child: const Text('Export to DOCX'),
                        onPressed: () async {
                          final location = await getSaveLocation(
                            suggestedName: 'document_docx',
                            acceptedTypeGroups: [
                              XTypeGroup(
                                label: 'DOCX',
                                extensions: ['docx'],
                                mimeTypes: [namespaces['documentType']!],
                                uniformTypeIdentifiers: [
                                  namespaces['documentType']!,
                                ],
                              ),
                            ],
                          );
                          if (location != null) {
                            final parser = DeltaToDocx(
                              options: DocxParserOptions(
                                documentProperties: defaultDocumentProperties(
                                  title: 'document',
                                ),
                              ),
                            );
                            final bytes = await parser.build(
                              data: _controller.document.toDelta(),
                            );

                            if (bytes != null || bytes!.isNotEmpty) {
                              final XFile textFile = XFile.fromData(
                                bytes,
                                mimeType: namespaces['documentType']!,
                                name: 'document.docx',
                              );
                              await textFile.saveTo(location.path);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
                // Quill toolbar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                    vertical: 8.0,
                  ),
                  child: QuillSimpleToolbar(
                    controller: _controller,
                    config: const QuillSimpleToolbarConfig(),
                  ),
                ),
              ],
            ),

            // Tab 3: Markdown Editor
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _markdownTextController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText:
                      'Start typing markdown here (e.g., # Heading, **bold**)...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
MaterialButton(
                  onPressed: () async {
                    final location = await getSaveLocation(
                      suggestedName: 'document_docx',
                      acceptedTypeGroups: [
                        XTypeGroup(
                          label: 'DOCX',
                          extensions: ['docx'],
                          mimeTypes: [namespaces['documentType']!],
                          uniformTypeIdentifiers: [namespaces['documentType']!],
                        ),
                      ],
                    );
                    if (location != null) {
                      final sdk = DocxDocumentSdk(
                        options: defaultDocumentProperties(
                          title: 'Document example',
                        ),
                      );
                      final Uint8List? bytes = await sdk.createDocument(
                        supportedFileExtensions: {},
                        DocxComponentContainer(
                          contents: [
                            Paragraph(
                              data: [
                                TextRun(
                                  data: TextPart(
                                    text: 'This is a part of the text where',
                                  ),
                                ),
                                TextRun(
                                  data: TextPart(
                                    text: ' your can use ',
                                    styles: <NodeAttribute>[BoldAttribute()],
                                  ),
                                ),
                                HyperlinkRun(
                                  data: HyperlinkTextPart(
                                    hyperlink: 'https://www.google.com',
                                    text: 'and this is a secondary link',
                                  ),
                                ),
                                // ImageContent(
                                //   data: ImageData(
                                //     bytes: await file.readAsBytes(),
                                //     extension: 'jpg',
                                //     width: 3400000,
                                //     height: 200000,
                                //   ),
                                // ),
                                TextRun(
                                  data: TextPart(
                                    text: ' and you after a image',
                                    styles: <NodeAttribute>[BoldAttribute()],
                                  ),
                                ),
                              ],
                            ),
                            Paragraph(
                              data: [
                                TextRun(
                                  data: TextPart(
                                    text: ' your can use',
                                    styles: <NodeAttribute>[BoldAttribute()],
                                  ),
                                ),
                                TextRun(data: TextPart(text: '\nYeah')),
                                /*
                                ImageContent(
                                  data: ImageData(
                                    bytes: await file.readAsBytes(),
                                    extension: 'jpeg',
                                    width: 3400000,
                                    height: 200000,
                                  ),
                                ),*/
                              ],
                            ),
                          ],
                        ),
                      );
                      final XFile textFile = XFile.fromData(
                        bytes!,
                        mimeType: namespaces['documentType']!,
                        name: 'document4.docx',
                      );
                      await textFile.saveTo(location.path);
                    }
                  },
                  child: Text('export data to plain docx'),
                )
*/
