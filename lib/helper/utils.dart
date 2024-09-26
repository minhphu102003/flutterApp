// Hàm chuyển đổi giá trị chỉ số UV (UVI) thành chuỗi mô tả mức độ
String uviValueToString(double uvi) {
  // Kiểm tra giá trị UVI và trả về mức độ tương ứng
  if (uvi <= 2) {
    return 'Low'; // Mức độ thấp
  } else if (uvi <= 5) {
    return 'Medium'; // Mức độ trung bình
  } else if (uvi <= 7) {
    return 'High'; // Mức độ cao
  } else if (uvi <= 10) {
    return 'Very High'; // Mức độ rất cao
  } else if (uvi >= 11) {
    return 'Extreme'; // Mức độ cực kỳ cao
  }
  return 'Unknown'; // Trả về 'Unknown' nếu không khớp với điều kiện nào
}

// Hàm lấy đường dẫn đến hình ảnh thời tiết dựa trên loại thời tiết đầu vào
String getWeatherImage(String input) {
  String weather = input.toLowerCase(); // Chuyển đổi chuỗi đầu vào thành chữ thường
  String assetPath = 'assets/images/'; // Đường dẫn đến thư mục hình ảnh

  // Sử dụng switch để xác định loại thời tiết và trả về đường dẫn hình ảnh tương ứng
  switch (weather) {
    case 'thunderstorm':
      return assetPath + 'Storm.png'; // Hình ảnh cho bão

    case 'drizzle':
    case 'rain':
      return assetPath + 'Rainy.png'; // Hình ảnh cho mưa

    case 'snow':
      return assetPath + 'Snow.png'; // Hình ảnh cho tuyết

    case 'clear':
      return assetPath + 'Sunny.png'; // Hình ảnh cho trời trong xanh

    case 'clouds':
      return assetPath + 'Cloudy.png'; // Hình ảnh cho trời nhiều mây

    case 'mist':
    case 'fog':
    case 'smoke':
    case 'haze':
    case 'dust':
    case 'hand':
    case 'ash':
      return assetPath + 'Fog.png'; // Hình ảnh cho sương mù hoặc khói

    case 'squall':
    case 'tornado':
      return assetPath + 'StormWindy.png'; // Hình ảnh cho bão hoặc lốc xoáy

    default:
      return assetPath + 'Cloud.png'; // Hình ảnh mặc định cho các loại thời tiết không xác định
  }
}
