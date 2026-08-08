import 'video_player_platform_io.dart' if (dart.library.html) 'video_player_platform_web.dart'
    as impl;

/// Creates a [VideoPlayerController] for a locally picked video file.
///
/// Native builds use `VideoPlayerController.file`; web builds convert the
/// [XFile] to an object URL and use `VideoPlayerController.networkUrl`.
Future<T> controllerForVideoFile<T>(
  dynamic file, {
  dynamic videoPlayerOptions,
}) =>
    impl.controllerForVideoFile(
      file,
      videoPlayerOptions: videoPlayerOptions,
    );