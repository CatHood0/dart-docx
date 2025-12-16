import 'dart:async';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import '../../../docx.dart';
import '../docx_compiler.dart';
import '../events/docx_event.dart';

class XmlOverrideFile {
  XmlOverrideFile({required this.data, required this.path});

  final String data;
  final String path;
}

/// Packs various metadata XML files for the DOCX document.
class DocxMetadataPacker {
  final DocxCompiler compiler = DocxCompiler();
  final ZipEncoder _encoder = ZipEncoder();

  static final DocxMetadataPacker instance = DocxMetadataPacker();

  Future<Uint8List?> bytes(
    DocxDocument document, {
    List<XmlOverrideFile> overrides = const <XmlOverrideFile>[],
  }) async {
    final Archive? zip = await compiler.compile(document);
    if (zip == null) return null;
    return _encoder.encodeBytes(
      zip,
      autoClose: true,
      level: DeflateLevel.defaultCompression,
    );
  }

  Future<Uint8List?> stream(
    DocxDocument document, {
    required void Function(Stream<DocxEvent>) onStream,
    List<XmlOverrideFile> overrides = const <XmlOverrideFile>[],
  }) async {
    onStream(compiler.eventStream);
    final Archive? zip = await compiler.compile(document);
    if (zip == null) return null;
    return _encoder.encodeBytes(
      zip,
      autoClose: true,
      level: DeflateLevel.defaultCompression,
    );
  }
}
