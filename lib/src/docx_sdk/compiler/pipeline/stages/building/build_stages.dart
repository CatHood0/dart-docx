/// Build Stages - Generan los archivos XML del documento DOCX.
///
/// Estos stages construyen los componentes XML y los añaden al archive:
/// - ContentTypeBuildStage: [Content_Types].xml
/// - RelsBuildStage: _rels/.rels
/// - CorePropsBuildStage: docProps/core.xml
/// - AppPropsBuildStage: docProps/app.xml
/// - DocumentRelsBuildStage: word/_rels/document.xml.rels
/// - DocumentBuildStage: word/document.xml
/// - NumberingBuildStage: word/numbering.xml
/// - StylesBuildStage: word/styles.xml
/// - FontTableBuildStage: word/fontTable.xml
/// - FontRelsBuildStage: word/_rels/fontTable.xml.rels
/// - SettingsBuildStage: word/settings.xml
/// - ThemeBuildStage: word/theme/theme1.xml
/// - WebSettingsBuildStage: word/webSettings.xml
library;

export 'app_props_build_stage.dart';
export 'content_type_build_stage.dart';
export 'core_props_build_stage.dart';
export 'document_build_stage.dart';
export 'document_rels_build_stage.dart';
export 'font_rels_build_stage.dart';
export 'font_table_build_stage.dart';
export 'numbering_build_stage.dart';
export 'rels_build_stage.dart';
export 'settings_build_stage.dart';
export 'styles_build_stage.dart';
export 'theme_build_stage.dart';
export 'web_settings_build_stage.dart';
