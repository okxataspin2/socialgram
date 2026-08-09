// ignore_for_file: public_member_api_docs

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:ffmpeg_wasm/ffmpeg_wasm.dart';
import 'package:web/web.dart' as web;

/// Web implementation of the video helpers.
///
/// Compression runs real FFmpeg in the browser through `ffmpeg.wasm`;
/// thumbnails are captured from a `<video>` element onto a `<canvas>`.
class VideoPlus {
  const VideoPlus._();

  static FFmpeg? _ffmpeg;

  static const _corePath =
      'https://unpkg.com/@ffmpeg/core@0.12.6/dist/ffmpeg-core.js';

  static Future<FFmpeg> _instance() async {
    final existing = _ffmpeg;
    if (existing != null) return existing;
    final ffmpeg = createFFmpeg(
      CreateFFmpegParam(log: false, corePath: _corePath),
    );
    if (!ffmpeg.isLoaded()) {
      await ffmpeg.load();
    }
    return _ffmpeg = ffmpeg;
  }

  /// Captures the first frame of the video as JPEG bytes.
  static Future<Uint8List?> getVideoThumbnail(Object file) async {
    final bytes = await (file as XFile).readAsBytes();
    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: 'video/mp4'),
    );
    final url = web.URL.createObjectURL(blob);
    try {
      final video = web.HTMLVideoElement()
        ..src = url
        ..muted = true
        ..playsInline = true;

      await video.onLoadedMetadata.first
          .timeout(const Duration(seconds: 15));
      video.currentTime = 0.05;
      await video.onSeeked.first.timeout(const Duration(seconds: 10));

      final canvas = web.HTMLCanvasElement()
        ..width = video.videoWidth
        ..height = video.videoHeight;
      final ctx = canvas.getContext('2d');
      if (ctx is! web.CanvasRenderingContext2D) return null;
      ctx.drawImage(video, 0, 0);

      final dataUrl = canvas.toDataURL('image/jpeg', 0.8.toJS);
      final parts = dataUrl.split(',');
      if (parts.length != 2) return null;
      final base64 = parts[1];
      final raw = base64
          .replaceAll(RegExp(r'\s'), '')
          .replaceAll('-', '+')
          .replaceAll('_', '/');
      return _decodeBase64(raw);
    } finally {
      web.URL.revokeObjectURL(url);
    }
  }

  static Uint8List _decodeBase64(String input) {
    final buffer = <int>[];
    var bits = 0;
    var value = 0;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    for (final char in input.codeUnits) {
      if (char == 61) break; // '='
      final index = chars.indexOf(String.fromCharCode(char));
      if (index == -1) continue;
      value = (value << 6) | index;
      bits += 6;
      if (bits >= 8) {
        bits -= 8;
        buffer.add((value >> bits) & 0xff);
      }
    }
    return Uint8List.fromList(buffer);
  }

  /// Compresses the video with FFmpeg and returns the compressed bytes.
  static Future<Uint8List?> compressVideo(Object file) async {
    final input = await (file as XFile).readAsBytes();
    final ffmpeg = await _instance();

    ffmpeg.writeFile('input.mp4', input);
    try {
      await ffmpeg.runCommand(
        '-i input.mp4 '
        '-vf "scale=min(1280,iw):-2" '
        '-c:v libx264 -preset veryfast -crf 28 '
        '-c:a aac -b:a 96k '
        '-movflags +faststart '
        'output.mp4',
      );
      return ffmpeg.readFile('output.mp4');
    } finally {
      try {
        ffmpeg.unlink('input.mp4');
        ffmpeg.unlink('output.mp4');
      } catch (_) {}
    }
  }
}