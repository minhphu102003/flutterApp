import 'package:flutter/material.dart';
import 'package:flutterApp/theme/colors.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final String? Function(String?) validator;
  final bool obscureText;
  final Icon prefixIcon;
  final ValueChanged<String>? onChanged;

  const CustomTextFormField({
    required this.hintText,
    required this.validator,
    required this.prefixIcon,
    this.onChanged,
    this.obscureText = false,
    Key? key,
  }) : super(key: key);

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  FocusNode focusNode = FocusNode();
  Color buttonColor = Colors.black;
  bool showPassword = false;
  bool isError = false; // Trạng thái lỗi

  @override
  void initState() {
    super.initState();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        // Reset trạng thái lỗi khi trường được focus
        setState(() {
          isError = false; // Đặt trạng thái lỗi về false
          buttonColor = primaryBlue; // Hoặc màu mặc định của bạn
        });
      } else {
        // Cập nhật lại màu khi không focus
        setState(() {
          buttonColor = Colors.black;
        });
      }
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          focusNode: focusNode,
          validator: (value) {
            final validationResult = widget.validator(value);
            if (validationResult != null) {
              setState(() {
                isError = true; // Đặt trạng thái lỗi nếu có thông báo
              });
            }
            return validationResult;
          },
          obscureText: widget.obscureText && !showPassword,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: isError ? Colors.red : buttonColor, // Màu đỏ nếu có lỗi
              ),
            ),
            labelText: widget.hintText,
            hintStyle: TextStyle(
              color: Color(0xFFb2b7bf),
              fontSize: 18.0,
            ),
            prefixIcon: Icon(
              widget.prefixIcon.icon,
              color: buttonColor,
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    icon: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off,
                      color: buttonColor,
                    ),
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: buttonColor), // Màu cho border khi trường đang hoạt động
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: buttonColor), // Màu cho border khi trường đang được chọn
            ),
          ),
          onChanged: (value) {
            // Reset trạng thái lỗi và màu sắc khi người dùng nhập giá trị
            setState(() {
              isError = false; // Đặt trạng thái lỗi về false
              buttonColor = primaryBlue; // Đặt màu về màu bình thường
            });
            if( widget.onChanged != null){
              widget.onChanged!(value);
            }
          },
        ),
      ],
    );
  }
}
