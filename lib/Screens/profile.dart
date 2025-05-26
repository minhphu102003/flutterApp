import 'package:flutter/material.dart';
import 'package:flutterApp/services/accountService.dart';
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
  final AccountService _accountService = AccountService();

  @override
  void initState() {
    super.initState();
    loadProfile(context, setState);
  }

  Future<void> showUpdateProfileDialog(
    BuildContext context, {
    required String name,
    required String email,
    required String phone,
    required void Function(String, String, String) onSave,
  }) async {
    final nameController = TextEditingController(text: name);
    final emailController = TextEditingController(text: email);
    final phoneController = TextEditingController(text: phone);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(
                nameController.text.trim(),
                emailController.text.trim(),
                phoneController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void updateProfile(
      BuildContext context, String name, String email, String phone) async {
    final updatedAccount = await _accountService.updateProfile(
      username: name,
      email: email,
      phone: phone,
    );

    if (updatedAccount != null) {
      this.name = updatedAccount.username;
      this.email = updatedAccount.email;
      this.phone = updatedAccount.phone;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Update Successful"),
          content: const Text("Your profile information has been updated."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Update Failed"),
          content: const Text("An error occurred while updating your profile."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }
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
            InfoTile(
                icon: Icons.person_outline, label: "Name", value: name ?? ""),
            const SizedBox(height: 20.0),
            InfoTile(
                icon: Icons.mail_outline, label: "Email", value: email ?? ""),
            const SizedBox(height: 20.0),
            InfoTile(
                icon: Icons.phone_outlined, label: "Phone", value: phone ?? ""),
            const SizedBox(height: 20.0),
            ActionTile(
              icon: Icons.edit_outlined,
              label: "Update Profile",
              onTap: () {
                showUpdateProfileDialog(
                  context,
                  name: name ?? "",
                  email: email ?? "",
                  phone: phone ?? "",
                  onSave: (newName, newEmail, newPhone) {
                    setState(() {
                      name = newName;
                      email = newEmail;
                      phone = newPhone;
                    });
                    updateProfile(context, newName, newEmail, newPhone);
                  },
                );
              },
            ),
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
