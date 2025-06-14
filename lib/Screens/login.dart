import 'package:flutter/material.dart';
import 'package:flutterApp/screens/forgot_password.dart';
import 'package:flutterApp/screens/sign.dart';
import 'package:flutterApp/helper/validators.dart';
import 'package:flutterApp/widgets/customTextFormField.dart';
import 'package:flutterApp/services/authService.dart';
import 'package:flutterApp/models/auth.dart';
import 'package:flutterApp/services/apiRespone.dart';
import 'package:flutterApp/widgets/customDialog.dart';
import 'package:flutterApp/theme/colors.dart';
import "package:flutterApp/screens/bottomnav.dart";
import 'package:flutterApp/helper/appConfig.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  final TextEditingController emailControler = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String dirImg = AppConfig.dirImg;

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

  @override
  void dispose() {
    emailControler.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              "$dirImg/6ecaa6adda417ea842eeadc75dce2c4a-removebg-preview.png",
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 30.0),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextFormField(
                        hintText: "Email",
                        controller: emailControler,
                        validator: emailValidator,
                        prefixIcon: const Icon(Icons.email),
                        onChanged: (value) {
                          email = value;
                        },
                      ),
                      const SizedBox(height: 30.0),
                      CustomTextFormField(
                        obscureText: true,
                        hintText: "Password",
                        controller: passwordController,
                        validator: passwordValidator,
                        prefixIcon: const Icon(Icons.lock),
                        onChanged: (value) {
                          password = value;
                        },
                      ),
                      const SizedBox(height: 30.0),
                      GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate()) {
                            ApiResponse<AuthToken?> apiResponse =
                                await AuthService().login(email, password);
                            if (apiResponse.error == null) {
                              emailControler.clear();
                              passwordController.clear();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const BottomNav()),
                              );
                            } else {
                              showCustomDialog(
                                  context,
                                  'Error',
                                  apiResponse.error!,
                                  Icons.error,
                                  failureColor, () {
                                // Ở đây không cần làm gì
                              });
                            }
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(
                              vertical: 13.0, horizontal: 30.0),
                          decoration: const BoxDecoration(
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
                      const SizedBox(height: 20.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPassword()));
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
                              "$dirImg/google.png",
                              height: 45,
                              width: 45,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 30.0),
                          GestureDetector(
                            onTap: () {},
                            child: Image.asset(
                              "$dirImg/apple1.png",
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
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Sign()));
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
