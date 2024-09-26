import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Định nghĩa màu sắc mặc định cho văn bản
const Color defaultTextColor = Colors.black;

// Định nghĩa kiểu chữ nhẹ
TextStyle lightText = GoogleFonts.openSans(
  fontSize: 12, // Kích thước chữ 12
  fontWeight: FontWeight.w300, // Trọng lượng chữ nhẹ
  color: defaultTextColor, // Màu sắc chữ
);

// Định nghĩa kiểu chữ thường
TextStyle regularText = GoogleFonts.openSans(
  fontSize: 14, // Kích thước chữ 14
  fontWeight: FontWeight.w400, // Trọng lượng chữ bình thường
  color: defaultTextColor, // Màu sắc chữ
);

// Định nghĩa kiểu chữ trung bình
TextStyle mediumText = GoogleFonts.openSans(
  fontSize: 16, // Kích thước chữ 16
  fontWeight: FontWeight.w500, // Trọng lượng chữ trung bình
  color: defaultTextColor, // Màu sắc chữ
);

// Định nghĩa kiểu chữ nửa đậm
TextStyle semiboldText = GoogleFonts.openSans(
  fontSize: 18, // Kích thước chữ 18
  fontWeight: FontWeight.w600, // Trọng lượng chữ nửa đậm
  color: defaultTextColor, // Màu sắc chữ
);

// Định nghĩa kiểu chữ đậm
TextStyle boldText = GoogleFonts.openSans(
  fontSize: 20, // Kích thước chữ 20
  fontWeight: FontWeight.w700, // Trọng lượng chữ đậm
  color: defaultTextColor, // Màu sắc chữ
);

// Định nghĩa kiểu chữ đen
TextStyle blackText = GoogleFonts.openSans(
  fontSize: 24, // Kích thước chữ 24
  fontWeight: FontWeight.w900, // Trọng lượng chữ đen
  color: defaultTextColor, // Màu sắc chữ
);
