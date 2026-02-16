import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../../docx.dart';

//TODO: add insert, delete, and replacement capabilities
//TODO: add capabilities to modify styles
//TODO: add capabilities to set new settings
//TODO: add capabilities to compile specific parts
//TODO: add mixins to components to allow detecting changes and recompiling automatically
/// The class encharged to allow general operations in the library
///
/// It's designed to allow granular updated instead generating whole
/// document files at every new change. This mean that if we insert
/// the character "a", only the document.xml file will be the unique
/// updated one
class DocxSdk {
  DocxSdk({
    required this.document,
    required this.archive,
  });

  final Archive archive;
  final DocxDocument document;

  //TODO: implement later granular info of the changes
  List<Object> operations = <Object>[];

  // to allow modifying certain parts of the docx result
  // we can implement these methods
  //
  // Aceppted types: String, Images and Paragraph
  void insert(int start, Object data) {}
  void replace(int start, int end, Object data) {}
  void delete(int start, int end) {}

  void insertStyle(DocumentStyles sheet) {}
  void removeStyle(String id, {String? name}) {}
  void updateStyle(String styleId, Style style) {}

  void updateSettings(SettingsOptions settings) {}

  /// New functions for document content and formatting
  void addParagraph(String text, {Style? style}) {}

  /// Add text to a specified paragraph
  void addTextToParagraph(
    int paragraphIndex,
    int offset,
    String text,
  ) {}

  /// Set a new style to a paragraph
  void setParagraphStyle(int paragraphIndex, Style style) {}

  void setRunAttributes(
    int paragraphIndex,
    int runIndex,
    List<TextRunAttribution> attributes,
  ) {}

  void insertPageBreak(int paragraphIndex) {}

  /// Build the entire new .docx file
  Future<Uint8List?> bytes() async {
    return DocxPacker().bytes(document);
  }

  Future<Uint8List?> tryChangesSave() async {
    return DocxPacker().bytes(document);
  }
}
