import 'package:flutter/material.dart';
import 'package:flutterApp/pages/login.dart';
import 'package:flutterApp/widgets/customTextFormField.dart';
import 'package:flutterApp/helper/validators.dart';
import 'package:flutterApp/services/authService.dart';
import 'package:flutterApp/widgets/customDialog.dart';
import 'package:flutterApp/theme/colors.dart';

class ResetPassword extends StatefulWidget {
  final String email;

  const ResetPassword({super.key, required this.email});

  @override
  _ResetPasswordState createState() {
    return _ResetPasswordState();
  }
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void showCustomDialog(BuildContext context, String title, String message,
      IconData typeIcon, Color color, VoidCallback onDialogClose) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            title: title,
            message: message,
            typeIcon: typeIcon,
            color: color,
            onDialogClose: onDialogClose,
          );
        });
  }

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      String password = _newPasswordController.text;
      print(password);
      String? response = await AuthService().resetPassword(
        widget.email,password!
      );
      if (response == null) {
        showCustomDialog(context, 'Notify', 'Reset password successfully',
            Icons.notifications, successColor, () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Login()));
        });
      } else {
        showCustomDialog(context, 'Error', response, Icons.error, failureColor,
            () {
          // Không thực hiện hành động gì
        });
      }
    } else {
      showCustomDialog(
          context, 'Error', 'Passwords do not match or invalid', Icons.error, failureColor, () {
        // Không thực hiện hành động gì
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Reset Password',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF273671),
      ),
      body: SafeArea(
        child: Container(
          height: screenSize.height,
          width: screenSize.width,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    child: Image.asset(
                      "assets/images/6ecaa6adda417ea842eeadc75dce2c4a-removebg-preview.png",
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    controller: _newPasswordController,
                    hintText: 'New Password',
                    validator: passwordValidator,
                    prefixIcon: const Icon(Icons.lock),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      } else if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.lock),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _resetPassword,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      width: screenSize.width * 0.8,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        color: const Color(0xFF273671),
                      ),
                      child: const Text(
                        'RESET PASSWORD',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
