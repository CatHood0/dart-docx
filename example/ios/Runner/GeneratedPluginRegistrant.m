//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<file_selector_ios/FileSelectorPlugin.h>)
#import <file_selector_ios/FileSelectorPlugin.h>
#else
@import file_selector_ios;
#endif

#if __has_include(<flutter_keyboard_visibility_temp_fork/FlutterKeyboardVisibilityTempForkPlugin.h>)
#import <flutter_keyboard_visibility_temp_fork/FlutterKeyboardVisibilityTempForkPlugin.h>
#else
@import flutter_keyboard_visibility_temp_fork;
#endif

#if __has_include(<image_picker_ios/FLTImagePickerPlugin.h>)
#import <image_picker_ios/FLTImagePickerPlugin.h>
#else
@import image_picker_ios;
#endif

#if __has_include(<path_provider_foundation/PathProviderPlugin.h>)
#import <path_provider_foundation/PathProviderPlugin.h>
#else
@import path_provider_foundation;
#endif

#if __has_include(<quill_native_bridge_ios/QuillNativeBridgePlugin.h>)
#import <quill_native_bridge_ios/QuillNativeBridgePlugin.h>
#else
@import quill_native_bridge_ios;
#endif

#if __has_include(<url_launcher_ios/URLLauncherPlugin.h>)
#import <url_launcher_ios/URLLauncherPlugin.h>
#else
@import url_launcher_ios;
#endif

#if __has_include(<video_player_avfoundation/FVPVideoPlayerPlugin.h>)
#import <video_player_avfoundation/FVPVideoPlayerPlugin.h>
#else
@import video_player_avfoundation;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FileSelectorPlugin registerWithRegistrar:[registry registrarForPlugin:@"FileSelectorPlugin"]];
  [FlutterKeyboardVisibilityTempForkPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterKeyboardVisibilityTempForkPlugin"]];
  [FLTImagePickerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTImagePickerPlugin"]];
  [PathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"PathProviderPlugin"]];
  [QuillNativeBridgePlugin registerWithRegistrar:[registry registrarForPlugin:@"QuillNativeBridgePlugin"]];
  [URLLauncherPlugin registerWithRegistrar:[registry registrarForPlugin:@"URLLauncherPlugin"]];
  [FVPVideoPlayerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FVPVideoPlayerPlugin"]];
}

@end
