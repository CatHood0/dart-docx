import 'dart:collection';

final UnmodifiableMapView<String, String> namespaces = UnmodifiableMapView(
  Map<String, String>.unmodifiable(
    <String, String>{
      // schemas namespaces
      'word': 'http://schemas.microsoft.com/office/word',
      'a': 'http://schemas.openxmlformats.org/drawingml/2006/main',
      'b': 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography',
      'cdr': 'http://schemas.openxmlformats.org/drawingml/2006/chartDrawing',
      'dc': 'http://purl.org/dc/elements/1.1/',
      'dcmitype': 'http://purl.org/dc/dcmitype/',
      'dcterms': 'http://purl.org/dc/terms/',
      'o': 'urn:schemas-microsoft-com:office:office',
      'pic': 'http://schemas.openxmlformats.org/drawingml/2006/picture',
      'r':
          'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
      'sl': 'http://schemas.openxmlformats.org/schemaLibrary/2006/main',
      'v': 'urn:schemas-microsoft-com:vml',
      've': 'http://schemas.openxmlformats.org/markup-compatibility/2006',
      'vt':
          'http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes',
      'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
      'w10': 'urn:schemas-microsoft-com:office:word',
      'wne': 'http://schemas.microsoft.com/office/word/2006/wordml',
      'cx': 'http://schemas.microsoft.com/office/drawing/2014/chartex',
      'cx1': 'http://schemas.microsoft.com/office/drawing/2015/9/8/chartex',
      'cx2': 'http://schemas.microsoft.com/office/drawing/2015/10/21/chartex',
      'cx3': 'http://schemas.microsoft.com/office/drawing/2016/5/9/chartex',
      'cx4': 'http://schemas.microsoft.com/office/drawing/2016/5/10/chartex',
      'cx5': 'http://schemas.microsoft.com/office/drawing/2016/5/11/chartex',
      'cx6': 'http://schemas.microsoft.com/office/drawing/2016/5/12/chartex',
      'cx7': 'http://schemas.microsoft.com/office/drawing/2016/5/13/chartex',
      'cx8': 'http://schemas.microsoft.com/office/drawing/2016/5/14/chartex',
      'aink': 'http://schemas.microsoft.com/office/drawing/2016/ink',
      'am3d': 'http://schemas.microsoft.com/office/drawing/2017/model3d',
      'wpc':
          'http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas',
      'wpg':
          'http://schemas.microsoft.com/office/word/2010/wordprocessingGroup',
      'wpi': 'http://schemas.microsoft.com/office/word/2010/wordprocessingInk',
      'wp':
          'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing',
      'wps':
          'http://schemas.microsoft.com/office/word/2010/wordprocessingShape',
      'wp14':
          'http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing',
      'w14': 'http://schemas.microsoft.com/office/word/2010/wordml',
      'w15': 'http://schemas.microsoft.com/office/word/2012/wordml',
      'w16cex': 'http://schemas.microsoft.com/office/word/2018/wordml/cex',
      'w16cid': 'http://schemas.microsoft.com/office/word/2016/wordml/cid',
      'w16': 'http://schemas.microsoft.com/office/word/2018/wordml',
      'w16sdtdh':
          'http://schemas.microsoft.com/office/word/2020/wordml/sdtdatahash',
      'w16se': 'http://schemas.microsoft.com/office/word/2015/wordml/symex',
      'mc': 'http://schemas.openxmlformats.org/markup-compatibility/2006',
      'm': 'http://schemas.openxmlformats.org/officeDocument/2006/math',
      'ignorable': 'w14 w15 w16se w16cid w16 w16cex w16sdtdh wp14',
      'xsd': 'http://www.w3.org/2001/XMLSchema',
      'xsi': 'http://www.w3.org/2001/XMLSchema-instance',
      'spreadsheet':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'contentTypes':
          'http://schemas.openxmlformats.org/package/2006/content-types',
      'relationship':
          'http://schemas.openxmlformats.org/package/2006/relationships',
      // for content type overrides
      'relationsXml':
          'application/vnd.openxmlformats-package.relationships+xml',
      'documentType':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml',
      'stylesType':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml',
      'numberingType':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml',
      'themeType': 'application/vnd.openxmlformats-officedocument.theme+xml',
      'fontTableType':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.fontTable+xml',
      'corePropsType':
          'application/vnd.openxmlformats-package.core-properties+xml',
      'settingsType':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml',
      'webSettingsType':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.webSettings+xml',
      'appType':
          'application/vnd.openxmlformats-officedocument.extended-properties+xml',
      'coreType': 'application/vnd.openxmlformats-package.core-properties+xml',
      // for _rels
      'officeDocumentRelation':
          'http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument',
      'numbering':
          'http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering',
      'font':
          'http://schemas.openxmlformats.org/officeDocument/2006/relationships/font',
      'fontTable':
          'http://schemas.openxmlformats.org/officeDocument/2006/relationships/fontTable',
      'hyperlinks':
          'http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink',
      'images':
          'http://schemas.openxmlformats.org/officeDocument/2006/relationships/image',
      'styles':
          'http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles',
      'headers':
          'http://schemas.openxmlformats.org/officeDocument/2006/relationships/header',
      'settings':
          'http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings',
      'webSettings':
          'http://schemas.openxmlformats.org/officeDocument/2006/relationships/webSettings',
      'footers':
          'http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer',
      'themes':
          'http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme',
      'extendedProperties':
          'http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties',
      'coreProperties':
          'http://schemas.openxmlformats.org/package/2006/metadata/core-properties',
      'corePropertiesRelation':
          'http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties',
    },
  ),
);
