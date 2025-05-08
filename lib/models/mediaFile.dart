import 'dart:io';
import 'dart:typed_data';
import 'package:flutterApp/utils/uint8List.dart';
import 'package:image_picker/image_picker.dart';

enum MediaType { image, video }

class MediaFile {
  final File file;
  final MediaType type;
  final Uint8List? thumbnail;

  MediaFile._({
    required this.file,
    required this.type,
    required this.thumbnail,
  });

  static Future<MediaFile> create({
    required File file,
    required MediaType type,
    Uint8List? thumbnail,
  }) async {
    if (type == MediaType.image) {
      return MediaFile._(
        file: file,
        type: type,
        thumbnail: null, 
      );
    }

    final resolvedThumbnail = thumbnail ??
        await loadAssetAsBytes('assets/images/video_placeholder.png');

    return MediaFile._(
      file: file,
      type: type,
      thumbnail: resolvedThumbnail,
    );
  }
}

