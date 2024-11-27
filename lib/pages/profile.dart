import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterApp/services/accountService.dart'; // Import AccountService
import 'package:flutterApp/pages/login.dart';
import 'package:flutterApp/widgets/support_widget.dart';
import 'package:flutterApp/services/authService.dart';
import 'package:flutterApp/widgets/customDialog.dart';
import 'package:flutterApp/theme/colors.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ImagePicker _picker = ImagePicker();
  final AccountService _accountService = AccountService();
  final AuthService _authService = AuthService();

  String? token;
  String? name;
  String? email;
  String? phone;
  File? selectedImage;

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
  void initState() {
    super.initState();
    _loadProfile();
  }

// void _navigateToLogin() {
//   SharedPreferences.getInstance().then((prefs) {
//     prefs.remove('token'); // Xóa token cũ để đảm bảo không sử dụng lại
//   });

//   // Điều hướng đến màn hình Login
//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(builder: (context) => const Login()),
//   );
// }

Future<void> _loadProfile() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    if (token == null) {
      // _navigateToLogin(); // Token không tồn tại, điều hướng đến Login
      return;
    }

    var response = await _accountService.getProfile();

    if (response['success']) {
      setState(() {
        name = response['data']['username'];
        email = response['data']['email'];
        phone = response['data']['phone'] ?? null;
      });
    } else {
      // Kiểm tra thông báo lỗi liên quan đến hết hạn token
      if (response['message'] == 'Error fetching profile') {
        // _navigateToLogin(); // Điều hướng đến màn hình Login
      } else {
        print('Error: ${response['message']}');
      }
    }
  } catch (e) {
    print('Failed to load profile: $e');
    // _navigateToLogin(); // Điều hướng khi có lỗi không xác định
  }
}

  Future<void> getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    } else {
      print("No image selected.");
    }
  }
  @override
  Widget build(BuildContext context) {
    if (name == null) {
      return const Login(); // Điều hướng tới màn hình đăng nhập nếu không có token
    } else {
      // Hiển thị giao diện Profile
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xfff2f2f2),
          centerTitle: true,
          title: Text(
            "Profile",
            style: AppWidget.boldTextFeildStyle().copyWith(
              fontSize: 24.0,
            ),
          ),
        ),
        backgroundColor: const Color(0xfff2f2f2),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Hiển thị avatar hoặc biểu tượng mặc định
              GestureDetector(
                onTap: getImage,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: selectedImage != null
                        ? Image.file(
                            selectedImage!,
                            height: 150.0,
                            width: 150.0,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.account_circle,
                            size: 150.0,
                            color: Colors.grey,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              // Hiển thị thông tin tên
              _buildInfoTile(
                icon: Icons.person_outline,
                label: "Name",
                value: name ?? "",
              ),
              const SizedBox(height: 20.0),
              // Hiển thị thông tin email
              _buildInfoTile(
                icon: Icons.mail_outline,
                label: "Email",
                value: email ?? "",
              ),
              const SizedBox(height: 20.0),
              _buildInfoTile(
                icon: Icons.phone_outlined,
                label: "Phone",
                value: phone ?? "",
              ),
              const SizedBox(height: 20.0),
              // Nút đăng xuất
              _buildActionTile(
                icon: Icons.logout_outlined,
                label: "Log Out",
                onTap: () async {
                  String message = await _authService.logOut();
                  if (message == 'Logout successful!') {
                    showCustomDialog(
                        context,
                        'Notify',
                        message,
                        Icons.notifications,
                        successColor, () {
                      setState(() {
                        token = null;
                      });
                    });
                  } else {
                      showCustomDialog(
                        context,
                        'Notify',
                        message,
                        Icons.error,
                        failureColor, () {
                    });
                  }
                },
              ),
              const SizedBox(height: 20.0),
              // Nút xóa tài khoản
              _buildActionTile(
                icon: Icons.delete_outline,
                label: "Delete Account",
                onTap: () {
                  // Thêm logic xóa tài khoản
                  print("Delete Account pressed");
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildInfoTile(
      {required IconData icon, required String label, required String value}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Material(
        elevation: 3.0,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 35.0),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppWidget.lightTextFeildStyle()),
                  Text(value, style: AppWidget.semiboldTextFeildStyle()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Material(
          elevation: 3.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, size: 35.0),
                const SizedBox(width: 10.0),
                Text(label, style: AppWidget.semiboldTextFeildStyle()),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_outlined),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
