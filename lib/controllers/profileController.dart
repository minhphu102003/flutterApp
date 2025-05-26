import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterApp/services/accountService.dart';
import 'package:flutterApp/services/authService.dart';
import 'package:flutterApp/screens/login.dart';
import 'package:flutterApp/widgets/customDialog.dart';
import 'package:flutterApp/theme/colors.dart';

mixin ProfileController {
  final ImagePicker _picker = ImagePicker();
  final AccountService _accountService = AccountService();
  final AuthService _authService = AuthService();

  String? token;
  String? name;
  String? email;
  String? phone;
  File? selectedImage;

  Future<void> loadProfile(
    BuildContext context,
    void Function(void Function()) setState,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
      if (token == null) return;

      var response = await _accountService.getProfile();
      if (response['success']) {
        setState(() {
          name = response['data']['username'];
          email = response['data']['email'];
          phone = response['data']['phone'];
        });
      }
    } catch (e) {
      print('Failed to load profile: $e');
    }
  }

  Future<void> getImage(void Function(void Function()) setState) async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  void handleLogout(
    BuildContext context,
    void Function(void Function()) setState,
  ) async {
    String message = await _authService.logOut();
    if (message == 'Logout successful!') {
      _showCustomDialog(
        context,
        'Notify',
        message,
        Icons.notifications,
        successColor,
        () {
          setState(() {
            token = null;
          });
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
            (route) => false,
          );
        },
      );
    } else {
      _showCustomDialog(
        context,
        'Notify',
        message,
        Icons.error,
        failureColor,
        () {},
      );
    }
  }

  void _showCustomDialog(
    BuildContext context,
    String title,
    String message,
    IconData typeIcon,
    Color color,
    VoidCallback onDialogClose,
  ) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        typeIcon: typeIcon,
        color: color,
        onDialogClose: onDialogClose,
      ),
    );
  }
}