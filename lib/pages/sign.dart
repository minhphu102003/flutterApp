import 'package:flutter/material.dart';
import 'package:flutterApp/pages/login.dart';
import 'package:flutterApp/widgets/customTextFormField.dart';
import 'package:flutterApp/helper/validators.dart';
import 'package:flutterApp/widgets/customDialog.dart';
import 'package:flutterApp/models/auth.dart';
import 'package:flutterApp/services/apiRespone.dart';
import 'package:flutterApp/services/authService.dart';
import 'package:flutterApp/theme/colors.dart';
import 'package:flutterApp/helper/appConfig.dart';

class Sign extends StatefulWidget {
  const Sign({super.key});

  @override
  State<Sign> createState() => _SignState();
}

class _SignState extends State<Sign> {
  final _formKey = GlobalKey<FormState>();
  String? username;
  String? email;
  String? password;
  String dirImg = AppConfig.dirImg;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Phần hình ảnh
              Container(
                width: size.width,
                height: size.height * 0.3, // Chiếm 30% chiều cao màn hình
                child: Image.asset(
                  "$dirImg/6ecaa6adda417ea842eeadc75dce2c4a-removebg-preview.png",
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10.0),
              const Text(
                "DANANG HUB CITY",
                style: TextStyle(
                  color: Color(0xFF273671),
                  fontSize: 28.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 20.0),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextFormField(
                            hintText: "Name",
                            validator: nameValidator,
                            controller: nameController,
                            prefixIcon: Icon(Icons.person),
                            onChanged: (value) {
                              username = value;
                            },
                          ),
                          const SizedBox(height: 20.0),
                          CustomTextFormField(
                            hintText: "Email",
                            validator: emailValidator,
                            controller: emailController,
                            prefixIcon: Icon(Icons.email),
                            onChanged: (value) {
                              email = value;
                            },
                          ),
                          const SizedBox(height: 20.0),
                          CustomTextFormField(
                            hintText: "Password",
                            obscureText: true,
                            validator: passwordValidator,
                            controller: passwordController,
                            prefixIcon: Icon(Icons.lock),
                            onChanged: (value) {
                              password = value;
                            },
                          ),
                          const SizedBox(height: 20.0),
                          GestureDetector(
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState!.validate()) {
                                ApiResponse<AuthToken?> apiResponse =
                                    await AuthService().signUp(
                                  username!,
                                  email!,
                                  password!,
                                );
                                if (apiResponse.error == null) {
                                  nameController.clear();
                                  emailController.clear();
                                  passwordController.clear();
                                  showCustomDialog(
                                    context,
                                    'Notify',
                                    'Registration successful!',
                                    Icons.notifications,
                                    successColor,
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Login(),
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  showCustomDialog(
                                    context,
                                    'Error',
                                    apiResponse.error!,
                                    Icons.error,
                                    failureColor,
                                    () {},
                                  );
                                }
                              }
                            },
                            child: Container(
                              width: size.width,
                              padding: EdgeInsets.symmetric(
                                vertical: 13.0,
                                horizontal: 30.0,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF273671),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Center(
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w500,
                                  ),
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
              // Dòng LogIn
              Column(
                children: [
                  const SizedBox(height: 20.0),
                  const Text(
                    "or LogIn with",
                    style: TextStyle(
                      color: Color(0xFF273671),
                      fontSize: 22.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "$dirImg/google.png",
                        height: 45,
                        width: 45,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 20.0),
                      Image.asset(
                        "$dirImg/apple1.png",
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Color(0xFF8c8e98),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 5.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Login(),
                            ),
                          );
                        },
                        child: const Text(
                          "LogIn",
                          style: TextStyle(
                            color: Color(0xFF273671),
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
