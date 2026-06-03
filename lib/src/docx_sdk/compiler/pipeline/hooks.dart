import 'package:archive/archive.dart';

import 'pipeline_context.dart';
import 'pipeline_stage.dart';

/// Hook executed before starting the compilation pipeline.
///
/// Useful for initialization, logging, or pre-compilation validation.
///
/// Usage example:
/// ```dart
/// pipeline.addPreCompileHook((context) {
///   print('Starting compilation at ${DateTime.now()}');
/// });
/// ```
typedef PreCompileHook = void Function(PipelineContext context);

/// Hook executed after completing the compilation pipeline.
///
/// Useful for cleanup, post-compilation logging, or result verification.
///
/// Usage example:
/// ```dart
/// pipeline.addPostCompileHook((context, archive) {
///   print('Compilation ${archive != null ? "succeeded" : "failed"}');
/// });
/// ```
typedef PostCompileHook = void Function(PipelineContext context, Archive? archive);

/// Hook executed before or after each pipeline stage.
///
/// Useful for detailed logging, debugging, or progress monitoring.
///
/// Usage example:
/// ```dart
/// pipeline.addPreStageHook((context, stage) {
///   print('Starting stage: ${stage.name}');
/// });
///
/// pipeline.addPostStageHook((context, stage) {
///   print('Completed stage: ${stage.name}');
/// });
/// ```
typedef StageHook = void Function(PipelineContext context, PipelineStage stage);
