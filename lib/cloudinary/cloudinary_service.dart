import 'package:cross_file/cross_file.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:env/env.dart';

/// Cloudinary service for uploading and managing media assets.
/// Made by RWAGENCY
class CloudinaryService {
  CloudinaryService();

  static String get _cloudName => Env.cloudinaryCloudName.value;
  static String get _uploadPreset => Env.cloudinaryUploadPreset.value;

  /// Maximum file sizes
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
  static const int maxStoryDuration = 20; // 20 seconds

  /// Upload image with validation
  Future<String?> uploadImage({
    required String userId,
    required XFile file,
    required MediaCategory category,
    String? customPublicId,
  }) async {
    final fileBytes = await file.readAsBytes();
    if (fileBytes.length > maxImageSize) {
      throw Exception('Image must be under 5MB');
    }

    final folder = _getFolder(category, userId);
    final publicId = customPublicId ?? '${userId}_${DateTime.now().millisecondsSinceEpoch}';

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = folder
      ..fields['public_id'] = publicId
      ..fields['transformation'] = 'q_auto,f_auto,w_1080'
      ..fields['format'] = 'auto'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: file.name,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      return _extractUrl(responseString);
    }
    return null;
  }

  /// Upload video with validation
  Future<String?> uploadVideo({
    required String userId,
    required XFile file,
    required MediaCategory category,
    required int durationSeconds,
  }) async {
    if (durationSeconds > maxStoryDuration) {
      throw Exception('Video must be $maxStoryDuration seconds or less');
    }

    final fileBytes = await file.readAsBytes();
    if (fileBytes.length > maxVideoSize) {
      throw Exception('Video must be under 50MB');
    }

    final folder = _getFolder(category, userId);
    final publicId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/video/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = folder
      ..fields['public_id'] = publicId
      ..fields['transformation'] = 'q_auto,f_mp4,w_720'
      ..fields['resource_type'] = 'video'
      ..fields['format'] = 'mp4'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: file.name,
          contentType: MediaType('video', 'mp4'),
        ),
      );

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      return _extractUrl(responseString);
    }
    return null;
  }

  /// Generate optimized URL for image
  String getOptimizedImageUrl(String publicId, {int? width, int? height}) {
    final transforms = <String>['q_auto'];
    if (width != null) transforms.add('w_$width');
    if (height != null) transforms.add('h_$height');
    transforms.add('f_auto');

    return 'https://res.cloudinary.com/$_cloudName/image/upload/'
        '${transforms.join(",")}/$publicId';
  }

  /// Generate thumbnail URL
  String getThumbnailUrl(String publicId, {int width = 300, int height = 300}) {
    return 'https://res.cloudinary.com/$_cloudName/image/upload/'
        'q_auto,f_auto,w_$width,h_$height,c_thumb/$publicId';
  }

  /// Generate optimized video URL
  String getOptimizedVideoUrl(String publicId, {int width = 720}) {
    return 'https://res.cloudinary.com/$_cloudName/video/upload/'
        'q_auto,f_mp4,w_$width/$publicId';
  }

  /// Delete asset from Cloudinary
  Future<bool> deleteAsset(String publicId) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/destroy',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['public_id'] = publicId
      ..fields['timestamp'] = DateTime.now().millisecondsSinceEpoch.toString()
      ..fields['invalidate'] = 'true'
      ..fields['type'] = 'upload';

    final response = await request.send();
    return response.statusCode == 200;
  }

  /// Get folder path based on category and user ID
  String _getFolder(MediaCategory category, String userId) {
    switch (category) {
      case MediaCategory.profile:
        return 'socialgram/users/$userId';
      case MediaCategory.post:
        return 'socialgram/posts';
      case MediaCategory.story:
        return 'socialgram/stories';
      case MediaCategory.chat:
        return 'socialgram/chat';
    }
  }

  /// Extract secure URL from Cloudinary response
  String _extractUrl(String responseString) {
    final startIndex = responseString.indexOf('"secure_url":"') + 14;
    final endIndex = responseString.indexOf('"', startIndex);
    return responseString.substring(startIndex, endIndex);
  }
}

/// Categories of media in the app
enum MediaCategory {
  /// Profile pictures
  profile,

  /// Posts (images/videos)
  post,

  /// Stories (videos/images)
  story,

  /// Chat messages (images/videos)
  chat,
}