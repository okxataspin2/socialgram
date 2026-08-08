
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/cloudinary/cloudinary_service.dart';

/// Cloudinary upload utilities for SocialGram
/// Made by RWAGENCY
class CloudinaryUploader {
  CloudinaryUploader._();

  /// Upload profile picture with validation
  static Future<String?> uploadProfilePicture({
    required BuildContext context,
    required XFile file,
    required String userId,
  }) async {
    final service = CloudinaryService();
    try {
      final url = await service.uploadImage(
        userId: userId,
        file: file,
        category: MediaCategory.profile,
      );
      return url;
    } catch (e) {
      _showError(context, e.toString());
      return null;
    }
  }

  /// Upload post image with validation
  static Future<String?> uploadPostImage({
    required BuildContext context,
    required XFile file,
    required String userId,
  }) async {
    final service = CloudinaryService();
    try {
      final url = await service.uploadImage(
        userId: userId,
        file: file,
        category: MediaCategory.post,
      );
      return url;
    } catch (e) {
      _showError(context, e.toString());
      return null;
    }
  }

  /// Upload post video with validation (50MB, 20s max)
  static Future<String?> uploadPostVideo({
    required BuildContext context,
    required XFile file,
    required String userId,
    required int durationSeconds,
  }) async {
    if (durationSeconds > CloudinaryService.maxStoryDuration) {
      _showError(context, 'Video must be ${CloudinaryService.maxStoryDuration} seconds or less');
      return null;
    }

    final service = CloudinaryService();
    try {
      final url = await service.uploadVideo(
        userId: userId,
        file: file,
        category: MediaCategory.post,
        durationSeconds: durationSeconds,
      );
      return url;
    } catch (e) {
      _showError(context, e.toString());
      return null;
    }
  }

  /// Upload story video (20s max, auto-delete after 24h)
  static Future<String?> uploadStoryVideo({
    required BuildContext context,
    required XFile file,
    required String userId,
    required int durationSeconds,
  }) async {
    if (durationSeconds > CloudinaryService.maxStoryDuration) {
      _showError(context, 'Story must be ${CloudinaryService.maxStoryDuration} seconds or less');
      return null;
    }

    final service = CloudinaryService();
    try {
      final url = await service.uploadVideo(
        userId: userId,
        file: file,
        category: MediaCategory.story,
        durationSeconds: durationSeconds,
      );
      return url;
    } catch (e) {
      _showError(context, e.toString());
      return null;
    }
  }

  /// Upload story image
  static Future<String?> uploadStoryImage({
    required BuildContext context,
    required XFile file,
    required String userId,
  }) async {
    final service = CloudinaryService();
    try {
      final url = await service.uploadImage(
        userId: userId,
        file: file,
        category: MediaCategory.story,
      );
      return url;
    } catch (e) {
      _showError(context, e.toString());
      return null;
    }
  }

  /// Upload chat media
  static Future<String?> uploadChatMedia({
    required BuildContext context,
    required XFile file,
    required String userId,
    bool isVideo = false,
  }) async {
    final service = CloudinaryService();
    try {
      String? url;
      if (isVideo) {
        url = await service.uploadVideo(
          userId: userId,
          file: file,
          category: MediaCategory.chat,
          durationSeconds: CloudinaryService.maxStoryDuration,
        );
      } else {
        url = await service.uploadImage(
          userId: userId,
          file: file,
          category: MediaCategory.chat,
        );
      }
      return url;
    } catch (e) {
      _showError(context, e.toString());
      return null;
    }
  }

  static void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
