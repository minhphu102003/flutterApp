import 'package:latlong2/latlong.dart'; // Thư viện để làm việc với tọa độ địa lý

// Lớp để chứa dữ liệu địa lý, bao gồm tên và tọa độ
class GeocodeData {
  String name; // Tên địa điểm
  LatLng latLng; // Tọa độ địa lý (vĩ độ và kinh độ)

  // Constructor yêu cầu các thông số đầu vào
  GeocodeData({
    required this.name,
    required this.latLng
  });

  // Phương thức factory để khởi tạo đối tượng từ dữ liệu JSON
  factory GeocodeData.fromJson(Map<String, dynamic> json){
    return GeocodeData(
      name: json['name'], // Lấy tên từ JSON
      latLng: LatLng(json['lat'], json['lon']) // Tạo đối tượng LatLng từ vĩ độ và kinh độ
    );
  }
}
