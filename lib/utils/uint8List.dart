import 'package:flutter/services.dart' show Uint8List, rootBundle;

Future<Uint8List> loadAssetAsBytes(String path) async {
  return await rootBundle.load(path).then((byteData) => byteData.buffer.asUint8List());
}
