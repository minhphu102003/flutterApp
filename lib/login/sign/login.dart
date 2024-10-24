import 'package:flutter/material.dart';
import 'package:flutterApp/Screens/mapScreen.dart';
import 'package:flutterApp/login/sign/forgot_password.dart';
import 'package:flutterApp/login/sign/sign.dart';
import 'package:flutterApp/helper/validators.dart';
import 'package:flutterApp/widgets/customTextFormField.dart';
import 'package:flutterApp/services/authService.dart';
// import 'package:flutterApp/models/auth.dart';
import 'package:flutterApp/widgets/customDialog.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>(); // Khởi tạo GlobalKey cho Form
  String email = '';
  String password = '';

  void showCustomDialog(BuildContext context, String title, String message,
      IconData typeIcon, Color color) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
              title: title, message: message, typeIcon: typeIcon, color: color);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "assets/images/6ecaa6adda417ea842eeadc75dce2c4a-removebg-preview.png",
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 30.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey, // Đặt key cho Form
                child: Column(
                  children: [
                    CustomTextFormField(
                      hintText: "Email",
                      validator: emailValidator,
                      prefixIcon: Icon(Icons.email),
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                    const SizedBox(height: 30.0),
                    CustomTextFormField(
                      obscureText: true,
                      hintText: "Password",
                      validator: passwordValidator,
                      prefixIcon: Icon(Icons.lock),
                      onChanged: (value) {
                        password = value;
                      },
                    ),
                    const SizedBox(height: 30.0),
                    GestureDetector(
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        if (_formKey.currentState!.validate()) {
                          // Nếu form hợp lệ, điều hướng đến MapScreen
                          print('Email: $email');
                          print('Password: $password');
                          String? errorMessage = await ApiClient.login(
                            username: email,
                            password: password,
                          );
                          if (errorMessage == null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MapScreen()),
                            );
                          } else {
                            showCustomDialog(
                              context,
                              'Error',
                              errorMessage,
                              Icons.error, // Icon cho lỗi
                              Colors.red, // Màu cho lỗi
                            );
                            print(errorMessage);
                          }
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                            vertical: 13.0, horizontal: 30.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF273671),
                        ),
                        child: const Center(
                          child: Text(
                            "Log In",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22.0,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ForgotPassword()));
              },
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                    color: Color(0xFF8c8e98),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 40.0),
            const Text(
              "or LogIn with",
              style: TextStyle(
                  color: Color(0xFF273671),
                  fontSize: 22.0,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: Image.asset(
                    "assets/images/google.png",
                    height: 45,
                    width: 45,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 30.0),
                GestureDetector(
                  onTap: () {},
                  child: Image.asset(
                    "assets/images/apple1.png",
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(
                      color: Color(0xFF8c8e98),
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 5.0),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Sign()));
                  },
                  child: const Text(
                    "SignUp",
                    style: TextStyle(
                        color: Color(0xFF273671),
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
