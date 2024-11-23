import 'dart:io';
import 'package:image/image.dart' as img;

Future<File> convertImage(File file) async {
  final bytes = await file.readAsBytes();
  final image = img.decodeImage(bytes);
  if (image != null) {
    final jpgBytes = img.encodeJpg(image, quality: 85); // Chuyển đổi thành JPG
    final newFile = File(file.path.replaceAll(RegExp(r'\.(jpg|jpeg|png|gif)$'), '.jpg'));
    return await newFile.writeAsBytes(jpgBytes); // Lưu ảnh chuyển đổi
  } else {
    throw Exception('Failed to decode image');
  }
}