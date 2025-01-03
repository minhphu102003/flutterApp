String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please Enter E-mail';
  }
  bool emailValid = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
      .hasMatch(value);
  if (!emailValid) {
    return 'Enter valid email';
  }
  return null;
}

String? passwordValidator(String? value) {
  // Kiểm tra xem giá trị có null hoặc rỗng không
  if (value == null || value.isEmpty) {
    return 'Please enter a password.';
  }

  // Kiểm tra độ dài
  if (value.length < 8) {
    return 'Password must be at least 8 characters long.';
  }

  // Kiểm tra có ít nhất một chữ hoa
  if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
    return 'Password must include at least one uppercase letter.';
  }

  // Kiểm tra có ít nhất một chữ thường
  if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
    return 'Password must include at least one lowercase letter.';
  }

  // Kiểm tra có ít nhất một số
  if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
    return 'Password must include at least one digit.';
  }

  // Kiểm tra có ít nhất một ký tự đặc biệt
  if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(value)) {
    return 'Password must include at least one special character.';
  }

  // Nếu không có lỗi
  return null;
}

String? nameValidator(String? value){
  if (value == null || value.isEmpty) {
    return 'Please Enter Name';
  }
  return null;
}
