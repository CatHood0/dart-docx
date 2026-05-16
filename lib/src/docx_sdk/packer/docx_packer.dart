import 'dart:async';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import '../../../docx.dart';
import '../events/docx_event.dart';
import '../utils/logger/logger_configs.dart';

class XmlOverrideFile {
  XmlOverrideFile({required this.data, required this.path});

  final String data;
  final String path;
}

/// Packs various metadata XML files for the DOCX document.
class DocxPacker {
  final DocxCompiler _compiler = DocxCompiler();
  final ZipEncoder _encoder = ZipEncoder();

  static final DocxPacker instance = DocxPacker();

  /// Determines if the fonts will be registing also using the content
  /// of the document to build an efficient [fontTable] file
  ///
  /// If not, set to false, and use [fonts] properties from
  /// [DocumentOptions] to skip this step. Will throw Exception
  /// if [dynamicFontSearch] is false and [fonts] is not setted
  DocxPacker dynamicFontSearch(bool search) {
    _compiler.dynamicFontSearch = search;
    return this;
  }

  /// Determines if the paragraph will be created referencing the
  /// "Normal" style when it does not contain a paragraph level
  /// style reference or configuration
  DocxPacker setNormalIfNeeded(bool setNormal) {
    _compiler.applyNormalStyleIfNeeded = setNormal;
    return this;
  }

  DocxPacker noTrimRuns() {
    _compiler.noTrim = true;
    return this;
  }

  DocxPacker trimRuns() {
    _compiler.noTrim = false;
    return this;
  }

  /// Enables checking every Style.ref used in the Document content.
  ///
  /// This can make the compilation more slow, since every time we found
  /// a Style.ref, we need to request for existence to DocumentStyles
  DocxPacker checkStylReferences() {
    _compiler.checkStyleRefExistence = true;
    return this;
  }

  /// Determines the "Normal" style to be applied using
  /// `applyNormalStyleIfNeeded` as the falg
  DocxPacker defaultNormalStyle(Style style) {
    assert(style.isReference, 'the style passed must be a reference instance');
    _compiler.defaultNormalStyle = style;
    return this;
  }

  DocxPacker setMediaStore(MediaStore store) {
    _compiler.mediaStore = store;
    return this;
  }

  DocxPacker setFontStore(FontStore store) {
    _compiler.fontStore = store;
    return this;
  }

  DocxPacker setPhasesConfig(LoggablePhaseConfig phaseConfig) {
    _compiler.config = phaseConfig;
    return this;
  }

  DocxPacker logAllPaths() {
    _compiler.config = LoggablePhaseConfig(
      enabled: true,
      loggablePhases: <String>{
        ...DocxPaths.paths,
      },
    );
    return this;
  }

  DocxPacker logPath(String path) {
    _compiler.config = LoggablePhaseConfig(
      loggablePhases: <String>{
        ..._compiler.config.loggablePhases,
        path,
      },
      enabled: true,
    );
    return this;
  }
  
  DocxPacker log(void Function(String) callback)  {
    _compiler.config = LoggablePhaseConfig(
      loggablePhases: <String>{..._compiler.config.loggablePhases},
      level: _compiler.config.level,
      enabled: true,
      log: callback,
    );
    return this;
  }

  DocxPacker logLevel(LogLevel level) {
    _compiler.config = LoggablePhaseConfig(
      loggablePhases: <String>{..._compiler.config.loggablePhases},
      level: level,
      enabled: true,
    );
    return this;
  }

  DocxPacker logPaths(Iterable<String> paths) {
    paths.forEach(logPath);
    return this;
  }

  /// Release all resources in this packer
  void release() {
    _compiler.release();
  }

  Future<Uint8List?> execute(
    DocxDocument document, {
    List<XmlOverrideFile> overrides = const <XmlOverrideFile>[],
    bool applyCustomTheme = false,
  }) async {
    final Archive? zip = await _compiler.compile(
      document,
      applyCustomTheme: applyCustomTheme,
    );
    if (zip == null) return null;
    return _encoder.encodeBytes(
      zip,
      autoClose: true,
      level: DeflateLevel.defaultCompression,
    );
  }

  DocxPacker stream(void Function(Stream<DocxEvent>) stream) {
    stream(_compiler.eventStream);
    return this;
  }
}
