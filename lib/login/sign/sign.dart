import 'package:flutter/material.dart';
import 'package:flutterApp/Screens/mapScreen.dart';
import 'package:flutterApp/login/sign/login.dart';
import 'package:flutterApp/widgets/customTextFormField.dart';
import 'package:flutterApp/helper/validators.dart';

class Sign extends StatefulWidget {
  const Sign({super.key});

  @override
  State<Sign> createState() => _SignState();
}

class _SignState extends State<Sign> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Column(
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    "assets/images/6ecaa6adda417ea842eeadc75dce2c4a-removebg-preview.png",
                    fit: BoxFit.cover,
                  )),
              const Text(
                "DANANG HUB CITY",
                style: TextStyle(
                  color: Color(0xFF273671),
                  fontSize: 28.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextFormField(
                        hintText: "Name",
                        validator: nameValidator,
                        prefixIcon: Icon(Icons.person),
                        onChanged: (value){
                          name = value;
                        },
                      ),
                      const SizedBox(height: 30.0),
                      CustomTextFormField(
                        hintText: "Email",
                        validator: emailValidator,
                        prefixIcon: Icon(Icons.email),
                        onChanged: (value){
                          email = value;
                        },
                      ),
                      const SizedBox(height: 30.0),
                      CustomTextFormField(
                        hintText: "Password",
                        obscureText: true,
                        validator: passwordValidator,
                        prefixIcon: Icon(Icons.lock),
                        onChanged: (value){
                          password = value;
                        },
                      ),
                      const SizedBox(height: 30.0),
                      GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate()) {
                            
                            // Nếu form hợp lệ, điều hướng đến MapScreen
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => MapScreen()),
                            // );
                          }
                          // Không cần setState ở đây vì Form tự động xử lý thông báo lỗi
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 30.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF273671),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
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
              SizedBox(height: 40.0),
              Text(
                "or LogIn with",
                style: TextStyle(
                  color: Color(0xFF273671),
                  fontSize: 22.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/google.png", height: 45, width: 45, fit: BoxFit.cover),
                  SizedBox(width: 30.0),
                  Image.asset("assets/images/apple1.png", height: 50, width: 50, fit: BoxFit.cover),
                ],
              ),
              SizedBox(height: 40.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?", style: TextStyle(color: Color(0xFF8c8e98), fontSize: 18.0, fontWeight: FontWeight.w500)),
                  SizedBox(width: 5.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                    },
                    child: Text(
                      "LogIn",
                      style: TextStyle(color: Color(0xFF273671), fontSize: 20.0, fontWeight: FontWeight.w500),
                    ),
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
