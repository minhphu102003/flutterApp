import 'package:flutter/material.dart';
import '../controllers/profileController.dart';
import '../widgets/profileWidgets.dart';
import 'package:flutterApp/widgets/support_widget.dart';
import '../screens/login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with ProfileController {
  @override
  void initState() {
    super.initState();
    loadProfile(context, setState);
  }

  @override
  Widget build(BuildContext context) {
    if (name == null) {
      return const Login();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff2f2f2),
        centerTitle: true,
        title: Text(
          "Profile",
          style: AppWidget.boldTextFeildStyle().copyWith(fontSize: 24.0),
        ),
      ),
      backgroundColor: const Color(0xfff2f2f2),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AvatarPicker(
              selectedImage: selectedImage,
              onImagePick: () => getImage(setState),
            ),
            const SizedBox(height: 20.0),
            InfoTile(icon: Icons.person_outline, label: "Name", value: name ?? ""),
            const SizedBox(height: 20.0),
            InfoTile(icon: Icons.mail_outline, label: "Email", value: email ?? ""),
            const SizedBox(height: 20.0),
            InfoTile(icon: Icons.phone_outlined, label: "Phone", value: phone ?? ""),
            const SizedBox(height: 20.0),
            ActionTile(
              icon: Icons.logout_outlined,
              label: "Log Out",
              onTap: () => handleLogout(context, setState),
            ),
            const SizedBox(height: 20.0),
            ActionTile(
              icon: Icons.delete_outline,
              label: "Delete Account",
              onTap: () {
                print("Delete Account pressed");
              },
            ),
          ],
        ),
      ),
    );
  }
}