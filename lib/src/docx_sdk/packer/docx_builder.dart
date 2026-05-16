import 'dart:io';
import 'dart:typed_data';

import '../../../docx.dart' show DocumentRoot, DocxNode;

class DocumentBuilder {
  final DocumentRoot doc = DocumentRoot(sections: <DocxNode<dynamic>>[]);

  DocumentBuilder element({required DocxNode node}) {
    return this;
  }

  DocumentBuilder p({required String text}) {
    return this;
  }

  DocumentBuilder h1({required String text}) {
    return this;
  }

  DocumentBuilder h2({required String text}) {
    return this;
  }

  DocumentBuilder h3({required String text}) {
    return this;
  }

  DocumentBuilder h4({required String text}) {
    return this;
  }

  DocumentBuilder h5({required String text}) {
    return this;
  }

  DocumentBuilder table({required List<List<String>> cols}) {
    return this;
  }

  DocumentBuilder imageFile({
    required File image,
    required num width,
    required num height,
  }) {
    return this;
  }

  DocumentBuilder imageBytes({
    required Uint8List image,
    required num width,
    required num height,
  }) {
    return this;
  }

  DocumentBuilder list({required String type, required List<String> text}) {
    return this;
  }
}
