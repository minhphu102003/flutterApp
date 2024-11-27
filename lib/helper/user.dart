import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

Future<String> getUniqueId() async {
  final prefs = await SharedPreferences.getInstance();
  String? uniqueId = prefs.getString('uniqueId');
  
  if (uniqueId == null) {
    uniqueId = Uuid().v4();  // Tạo ID duy nhất nếu chưa có
    await prefs.setString('uniqueId', uniqueId); // Lưu ID vào SharedPreferences
  }
  
  return uniqueId;
}