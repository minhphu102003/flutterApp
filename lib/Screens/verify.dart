import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterApp/screens/resetPassword.dart';
import 'package:flutterApp/theme/colors.dart';
import 'package:flutterApp/services/authService.dart';
import 'package:flutterApp/widgets/customDialog.dart';
import 'package:flutterApp/helper/appConfig.dart';

class Verify extends StatefulWidget {
  final String email;

  const Verify({required this.email, super.key});

  @override
  _VerifyState createState() {
    return _VerifyState();
  }
}

class _VerifyState extends State<Verify> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  String dirImg  = AppConfig.dirImg;
  @override
  void dispose() {
    // Giải phóng bộ nhớ khi không sử dụng nữa
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Hàm để lấy giá trị OTP đã nhập
  String getOtp() {
    return _otpControllers.map((controller) => controller.text).join();
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

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Verify OTP',
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
          child: Column(
            children: [
              Container(
                  child: Image.asset(
                "$dirImg/6ecaa6adda417ea842eeadc75dce2c4a-removebg-preview.png",
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              )),
              const SizedBox(
                height: 20,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'OTP verification',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'OTP code has been sent to ',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.4),
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: widget.email, // Giá trị email
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontSize: 18,
                              fontWeight: FontWeight.bold, // In đậm
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: List.generate(6, (index) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: CodeVerify(
                          controller: _otpControllers[index],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              RichText(
                  text: TextSpan(
                      text: "Don't receive the OTP ",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.3),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                      children: <TextSpan>[
                    TextSpan(
                        text: "Resend OTP",
                        style: const TextStyle(
                          color: primaryBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            String? response = await AuthService()
                                .forgotPassword(widget.email);
                            if (response == null) {
                              showCustomDialog(context, 'Notify', 'Sent OTP successful',
                                  Icons.notifications, successColor, () {
                                // Không thực hiện hành động gì
                              });
                            } else {
                              showCustomDialog(context, 'Error', response,
                                  Icons.error, failureColor, () {
                                // Không thực hiện hành động gì
                              });
                            }
                          })
                  ])),
              const SizedBox(
                height: 20,
              ),
              Container(
                child: GestureDetector(
                  onTap: () async {
                    String otp = getOtp();
                    String? response =
                        await AuthService().verifyOTP(widget.email, otp!);
                    if (response == null) {
                      showCustomDialog(
                          context,
                          'Notify',
                          'OTP verify successfully',
                          Icons.notifications,
                          successColor, () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ResetPassword(email: widget.email)));
                      });
                    } else {
                      showCustomDialog(
                          context, 'Error', response, Icons.error, failureColor,
                          () {
                        // Không thực hiện hành động gì
                      });
                    }
                  }, // Gọi hàm API khi người dùng nhấn vào nút
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    width: screenSize.width * 0.8,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: const Color(0xFF273671),
                    ),
                    child: const Text(
                      'VERIFY',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}

class CodeVerify extends StatelessWidget {
  final TextEditingController controller;

  const CodeVerify({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength: 1,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 33,
        fontWeight: FontWeight.w500,
      ),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: TextStyle(
          color: Colors.black.withOpacity(0.3),
          fontWeight: FontWeight.w500,
          fontSize: 27,
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: primaryBlue,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
