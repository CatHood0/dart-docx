import 'package:xml/xml.dart';

import '../../../docx.dart';
import '../../core/extensions/string_ext.dart';

/// Manages glossary entries (building blocks) for a Docx document.
///
/// The glossary is a document part (`/word/glossary/document.xml`) that stores
/// reusable content blocks called "building blocks" or "docParts".
/// These can be referenced from SDT placeholders using their unique names.
///
/// ## Glossary Entry Types
/// - [GlossaryEntryType.placeholder] (`bbPlcHdr`): Placeholder text for form fields
/// - [GlossaryEntryType.autoText] (`bbAutoText`): Reusable text blocks
/// - [GlossaryEntryType.normal] (`bbNormal`): Normal building blocks
/// - [GlossaryEntryType.customAutoText] (`bbCustomAutoText`): Custom AutoText entries
///
/// ## Usage
/// ```dart
/// final glossaryStore = GlossaryStore();
///
/// // Add a placeholder entry
/// glossaryStore.addEntry(GlossaryEntry(
///   name: 'PlcHdr_Nombre',
///   type: GlossaryEntryType.placeholder,
///   body: [
///     Paragraph(
///       children: [
///         TextRun(
///           text: 'Enter name here...',
///           styles: [italic, color(gray)],
///         ),
///       ],
///     ),
///   ],
/// ));
///
/// // Build the glossary document
/// final glossaryXml = glossaryStore.buildGlossaryXmlComponent();
/// ```
///
/// See also:
/// - [GlossaryEntry] for individual entry structure
/// - [GlossaryEntryType] for available entry types
class GlossaryStore extends Store {
  GlossaryStore();

  /// Map of entries by their unique name.
  final Map<String, GlossaryEntry> _entries = <String, GlossaryEntry>{};

  @override
  String get storeName => 'Glossary Store';

  /// Returns all registered glossary entries.
  Iterable<GlossaryEntry> get entries => _entries.values;

  /// Returns the number of entries in the glossary.
  int get entryCount => _entries.length;

  /// Returns whether the glossary has any entries.
  bool get hasEntries => _entries.isNotEmpty;

  /// Returns an entry by its name, or null if not found.
  GlossaryEntry? getEntry(String name) => _entries[name];

  /// Returns whether an entry with the given name exists.
  bool hasEntry(String name) => _entries.containsKey(name);

  /// Adds a glossary entry.
  ///
  /// If an entry with the same name already exists, it will be replaced.
  ///
  /// [entry] The glossary entry to add.
  void addEntry(GlossaryEntry entry) {
    CompilerLogger.root.debug(
      'Adding glossary entry: ${entry.name} (type: ${entry.type.xmlValue})',
    );
    _entries[entry.name] = entry;
  }

  /// Removes a glossary entry by name.
  ///
  /// Returns true if the entry was removed, false if it didn't exist.
  bool removeEntry(String name) {
    final bool removed = _entries.remove(name) != null;
    if (removed) {
      CompilerLogger.root.debug('Removed glossary entry: $name');
    }
    return removed;
  }

  /// Clears all glossary entries.
  void clear() {
    CompilerLogger.root.debug(
      'Clearing all glossary entries (count: ${_entries.length})',
    );
    _entries.clear();
  }

  @override
  void reset() {
    clear();
  }

  @override
  void initialize(PipelineContext context) {
    // No special initialization needed
  }

  /// Builds the complete glossary document XML component.
  ///
  /// Returns an [XmlDocument] representing the `/word/glossary/document.xml` file.
  /// Returns null if there are no entries.
  XmlDocument? buildGlossaryXmlDocument() {
    if (!hasEntries) {
      CompilerLogger.root.debug('No glossary entries to build');
      return null;
    }

    CompilerLogger.root.debug(
      'Building glossary document with ${_entries.length} entries',
    );

    final List<XmlNode> docParts = <XmlNode>[];
    for (final GlossaryEntry entry in _entries.values) {
      docParts.add(entry.buildXml());
    }

    final XmlElement glossaryDocument = XmlElement.tag(
      'w:glossaryDocument',
      attributes: <XmlAttribute>[
        XmlAttribute(
          'xmlns:w'.toName(),
          'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
        ),
        XmlAttribute(
          'xmlns:r'.toName(),
          'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
        ),
      ],
      children: <XmlNode>[
        XmlElement.tag('w:docParts', children: docParts),
      ],
    );

    final XmlDocument document = XmlDocument();
    document.children.add(glossaryDocument);

    return document;
  }
}
