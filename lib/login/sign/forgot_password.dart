import 'package:flutter/material.dart';
import 'package:flutterApp/login/sign/verify.dart';
import 'package:flutterApp/widgets/customTextFormField.dart';
import 'package:flutterApp/helper/validators.dart';
import 'package:flutterApp/widgets/customDialog.dart';
import 'package:flutterApp/theme/colors.dart';
import 'package:flutterApp/services/authService.dart';
import 'package:flutterApp/helper/appConfig.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailControler = TextEditingController();
  String? email;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reset Password',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF273671),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width /
                    2, // Đảm bảo chiều rộng và chiều cao của container bằng nhau
                height: MediaQuery.of(context).size.width /
                    2, // Đảm bảo tỷ lệ 1:1 để giữ hình ảnh tròn
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color.fromARGB(255, 212, 212, 212),
                      width: 1.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width /
                          2), // Bo tròn với cùng tỷ lệ
                  child: Image.asset(
                    "$dirImg/6ecaa6adda417ea842eeadc75dce2c4a-removebg-preview.png",
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.width /
                        2, // Chiều cao và chiều rộng bằng nhau
                    fit: BoxFit
                        .cover, // Đảm bảo hình ảnh được phủ khít khung tròn
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 8),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      // Hoặc Expanded
                      child: Text(
                        'Please enter your registered email to reset your password.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center, // Căn giữa văn bản
                        maxLines: 2, // Số dòng tối đa
                        overflow: TextOverflow
                            .ellipsis, // Hiển thị ba chấm nếu văn bản quá dài
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              CustomTextFormField(
                hintText: 'Email',
                validator: emailValidator,
                prefixIcon: const Icon(Icons.email),
                controller: emailControler,
                onChanged: (value) {
                  email = value;
                },
              ),
              const SizedBox(
                height: 30.0,
              ),
              GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      String? responese =
                          await AuthService().forgotPassword(email!);
                      if (responese == null) {
                        showCustomDialog(
                            context,
                            'Notify',
                            'OTP sent successfully',
                            Icons.notifications,
                            successColor, () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Verify(email: email!)));
                        });
                      }else{
                        showCustomDialog(context, 'Error',responese,
                          Icons.error, failureColor, () {
                        // Không thực hiện hành động gì
                      });
                      }
                    } else {
                      showCustomDialog(context, 'Error', 'Invalid email',
                          Icons.error, failureColor, () {
                        // Không thực hiện hành động gì
                      });
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.height / 15,
                    decoration: BoxDecoration(
                        color: const Color(0xFF273671),
                        borderRadius: BorderRadius.circular(15)),
                    child: const Center(
                      child: Text(
                        'Reset Password',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
