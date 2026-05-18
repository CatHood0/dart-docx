import 'package:xml/xml.dart';

import '../../../../../docx.dart';
import '../../../../core/extensions/string_ext.dart';

/// Date picker SDT component with calendar dropdown.
///
/// Represents a `<w:sdt>` element with `w:date` type.
/// Displays a date picker with calendar dropdown for date selection.
///
/// ## XML Structure:
/// ```xml
/// <w:sdt>
///   <w:sdtPr>
///     <w:date>
///       <w:dateFormat w:val="dd/MM/yyyy"/>
///       <w:lid w:val="es-ES"/>
///       <w:storeMappedDataAs w:val="dateTime"/>
///       <w:calendar w:val="gregorian"/>
///     </w:date>
///     <w:alias w:val="Fecha de Firma"/>
///     <w:tag w:val="signature_date"/>
///     <w:id w:val="5001"/>
///   </w:sdtPr>
///   <w:sdtContent>
///     <w:r>
///       <w:t>16/05/2026</w:t>
///     </w:r>
///   </w:sdtContent>
/// </w:sdt>
/// ```
///
/// ## Example usage:
/// ```dart
/// final datePicker = SdtDate(
///   alias: 'Fecha de Firma',
///   tag: 'signature_date',
///   dateFormat: 'dd/MM/yyyy',
///   lid: 'es-ES',
///   calendar: SdtCalendar.gregorian,
///   value: DateTime(2026, 5, 16),
/// );
/// ```
///
/// See also:
/// - [docs/sdt_elements.md] for complete SDT documentation
class SdtDate extends Sdt<RunBase> with PrintableMixin {
  SdtDate({
    required String alias,
    required this.tag,
    required this.dateFormat,
    required String locale,
    String storeMappedDataAs = 'dateTime',
    SdtCalendar calendar = SdtCalendar.gregorian,
    DateTime? value,
    this.placeholder,
    this.showingPlacHdr = true,
    this.lock,
    this.temporary = false,
    super.parent,
    super.id,
    super.sdtId,
  })  : _alias = alias,
        _locale = locale,
        _storeMappedDataAs = storeMappedDataAs,
        _calendar = calendar,
        _value = value,
        _displayText = _formatDate(value, dateFormat),
        super(
            child: TextRun.text(
          text: _formatDate(value, dateFormat),
        ));

  /// The alias is the visible label in Word's content control UI.
  final String _alias;
  String get alias => _alias;

  /// Internal tag for programming reference.
  final String tag;

  /// Date format string (e.g., 'dd/MM/yyyy', 'yyyy-MM-dd').
  final String dateFormat;

  /// Language/locale identifier (e.g., 'es-ES', 'en-US').
  final String _locale;
  String get locale => _locale;

  /// How to store the mapped data (usually 'dateTime').
  final String _storeMappedDataAs;

  /// Calendar system to use.
  final SdtCalendar _calendar;

  /// The selected date value.
  final DateTime? _value;
  DateTime? get value => _value;

  /// The display text for the date value.
  final String _displayText;

  /// Placeholder text shown when no date is selected.
  final String? placeholder;

  /// Whether to show the placeholder text.
  final bool showingPlacHdr;

  /// Lock type to prevent editing.
  final StdLock? lock;

  /// If true, the SDT is temporary and not saved permanently.
  final bool temporary;

  /// Helper to format a DateTime to string.
  static String _formatDate(DateTime? value, String dateFormat) {
    if (value == null) return '';
    // Simple date formatting - in production would use intl package
    final Map<String, String> formatMap = <String, String>{
      'dd/MM/yyyy':
          '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}',
      'yyyy-MM-dd':
          '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}',
      'MM/dd/yyyy':
          '${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}/${value.year}',
    };
    return formatMap[dateFormat] ?? '${value.day}/${value.month}/${value.year}';
  }

  @override
  List<XmlElement> buildXml() {
    return <XmlElement>[
      XmlElement.tag(
        'w:sdt',
        children: <XmlNode>[
          _buildPropertiesXml(),
          _buildContentXml(),
        ],
      ),
    ];
  }

  XmlElement _buildPropertiesXml() {
    final List<XmlNode> children = <XmlNode>[
      XmlElement.tag(
        'w:date',
        children: <XmlNode>[
          // dateFormat
          XmlElement.tag(
            'w:dateFormat',
            attributes: <XmlAttribute>[
              XmlAttribute('w:val'.toName(), dateFormat),
            ],
            isSelfClosing: true,
          ),
          // lid (locale)
          XmlElement.tag(
            'w:lid',
            attributes: <XmlAttribute>[
              XmlAttribute('w:val'.toName(), _locale),
            ],
            isSelfClosing: true,
          ),
          // storeMappedDataAs
          XmlElement.tag(
            'w:storeMappedDataAs',
            attributes: <XmlAttribute>[
              XmlAttribute('w:val'.toName(), _storeMappedDataAs),
            ],
            isSelfClosing: true,
          ),
          // calendar
          XmlElement.tag(
            'w:calendar',
            attributes: <XmlAttribute>[
              XmlAttribute('w:val'.toName(), _calendar.value),
            ],
            isSelfClosing: true,
          ),
        ],
      ),
      XmlElement.tag(
        'w:alias',
        attributes: <XmlAttribute>[
          XmlAttribute('w:val'.toName(), _alias),
        ],
        isSelfClosing: true,
      ),
      XmlElement.tag(
        'w:tag',
        attributes: <XmlAttribute>[
          XmlAttribute('w:val'.toName(), tag),
        ],
        isSelfClosing: true,
      ),
    ];

    // Add id - use SdtStore to get unique ID
    final int actualSdtId = context.sdtStore.getNextId(
      nodeId: id,
      preferredId: sdtId,
    );
    children.add(
      XmlElement.tag(
        'w:id',
        attributes: <XmlAttribute>[
          XmlAttribute('w:val'.toName(), actualSdtId.toString()),
        ],
        isSelfClosing: true,
      ),
    );

    // Add placeholder
    if (placeholder != null) {
      children.add(
        XmlElement.tag(
          'w:placeholder',
          children: <XmlNode>[
            XmlElement.tag(
              'w:docPart',
              attributes: <XmlAttribute>[
                XmlAttribute('w:val'.toName(), placeholder!),
              ],
              isSelfClosing: true,
            ),
          ],
        ),
      );
    }

    // Add showingPlacHdr
    children.add(
      XmlElement.tag(
        'w:showingPlacHdr',
        attributes: <XmlAttribute>[
          XmlAttribute('w:val'.toName(), showingPlacHdr ? '1' : '0'),
        ],
        isSelfClosing: true,
      ),
    );

    // Add lock if provided
    if (lock != null) {
      children.add(
        XmlElement.tag(
          'w:lock',
          attributes: <XmlAttribute>[
            XmlAttribute('w:val'.toName(), lock!.type),
          ],
          isSelfClosing: true,
        ),
      );
    }

    // Add temporary if true
    if (temporary) {
      children.add(
        XmlElement.tag(
          'w:temporary',
          attributes: <XmlAttribute>[
            XmlAttribute('w:val'.toName(), '1'),
          ],
          isSelfClosing: true,
        ),
      );
    }

    return XmlElement.tag('w:sdtPr', children: children);
  }

  XmlElement _buildContentXml() {
    final List<XmlNode> runs = child.ensureInitialized(context).buildXml();
    return XmlElement.tag('w:sdtContent', children: runs);
  }

  @override
  List<XmlNode> buildXmlStyle() {
    return <XmlNode>[];
  }

  @override
  SdtDate get copy => SdtDate(
        sdtId: sdtId,
        alias: _alias,
        tag: tag,
        dateFormat: dateFormat,
        locale: _locale,
        storeMappedDataAs: _storeMappedDataAs,
        calendar: _calendar,
        value: _value,
        placeholder: placeholder,
        showingPlacHdr: showingPlacHdr,
        lock: lock,
        temporary: temporary,
        parent: parent,
      );

  @override
  SdtDate copyWith({
    RunBase? child,
    DocxNode<dynamic>? parent,
    String? id,
    String? alias,
    String? tag,
    String? dateFormat,
    String? lid,
    String? storeMappedDataAs,
    SdtCalendar? calendar,
    DateTime? value,
    String? placeholder,
    bool? showingPlacHdr,
    StdLock? lock,
    bool? temporary,
    int? sdtId,
  }) {
    return SdtDate(
      sdtId: sdtId ?? this.sdtId,
      alias: alias ?? _alias,
      tag: tag ?? this.tag,
      dateFormat: dateFormat ?? this.dateFormat,
      locale: lid ?? _locale,
      storeMappedDataAs: storeMappedDataAs ?? _storeMappedDataAs,
      calendar: calendar ?? _calendar,
      value: value ?? _value,
      placeholder: placeholder ?? this.placeholder,
      showingPlacHdr: showingPlacHdr ?? this.showingPlacHdr,
      lock: lock ?? this.lock,
      temporary: temporary ?? this.temporary,
      parent: parent ?? this.parent,
    );
  }

  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this)
        ? this
        : !visitChildrenIfNeeded
            ? null
            : child.visitElement(
                shouldGetElement,
                visitChildrenIfNeeded: visitChildrenIfNeeded,
              );
  }

  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this)
        ? <DocxNode<dynamic>>[this]
        : !visitChildrenIfNeeded
            ? null
            : child.visitAllElement(
                shouldGetElement,
                visitChildrenIfNeeded: visitChildrenIfNeeded,
              );
  }

  @override
  String toPlainText() => _displayText;

  @override
  String toString() {
    return 'SdtDate(alias: $_alias, tag: $tag, value: $_value)';
  }
}
