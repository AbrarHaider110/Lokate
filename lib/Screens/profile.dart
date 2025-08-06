import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController fullNameController;
  late TextEditingController userNameController;
  late TextEditingController contactController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  bool isLoading = true;
  bool isEditing = false;
  bool isUpdating = false;
  File? profileImage;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController();
    userNameController = TextEditingController();
    contactController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://your-api.com/GetUserProfile?userId=${widget.userId}',
        ),
        headers: {'Authorization': 'Bearer YOUR_ACCESS_TOKEN'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userData = data;
          fullNameController.text = data['fullName'] ?? '';
          userNameController.text = data['userName'] ?? '';
          contactController.text = data['contact'] ?? '';
          emailController.text = data['email'] ?? '';
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    userNameController.dispose();
    contactController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> updateProfile() async {
    if (!isEditing) {
      setState(() {
        isEditing = true;
      });
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      final updateData = {
        'UserId': widget.userId,
        'FullName': fullNameController.text.trim(),
        'UserName': userNameController.text.trim(),
        'Contact': contactController.text.trim(),
      };

      const url = 'https://your-api.com/UpdateProfile';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_ACCESS_TOKEN',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        await _fetchUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        setState(() {
          isEditing = false;
        });
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
      _uploadProfileImage();
    }
    Navigator.pop(context);
  }

  Future<void> _uploadProfileImage() async {
    if (profileImage == null) return;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://your-api.com/UploadProfileImage'),
      );
      request.headers['Authorization'] = 'Bearer YOUR_ACCESS_TOKEN';
      request.fields['userId'] = widget.userId.toString();
      request.files.add(
        await http.MultipartFile.fromPath('image', profileImage!.path),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        await _fetchUserData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: ${e.toString()}')),
      );
    }
  }

  void showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () => pickImage(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
                  onTap: () => pickImage(ImageSource.camera),
                ),
              ],
            ),
          ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            obscureText: obscure,
            enabled: enabled && isEditing,
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  isEditing
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(
              color: isEditing ? Colors.black87 : Colors.grey[700],
              fontSize: 14,
            ),
            cursorColor: Colors.black87,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: isUpdating ? null : updateProfile,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: screenWidth * 0.14,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          profileImage != null
                              ? FileImage(profileImage!)
                              : userData?['profileImageUrl'] != null
                              ? NetworkImage(userData!['profileImageUrl'])
                                  as ImageProvider
                              : null,
                      child:
                          profileImage == null &&
                                  userData?['profileImageUrl'] == null
                              ? Icon(
                                Icons.person,
                                size: screenWidth * 0.28,
                                color: Colors.grey[700],
                              )
                              : null,
                    ),
                  ),
                  if (isEditing)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: showImageSourceActionSheet,
                        child: Container(
                          height: 26,
                          width: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [0.001, 1.0],
                              colors: [
                                Color(0xFF1A9C8C),
                                Color.fromARGB(255, 2, 51, 164),
                              ],
                            ),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            buildTextField(
              label: "Full Name",
              controller: fullNameController,
              enabled: true,
            ),
            buildTextField(label: "Username", controller: userNameController),
            buildTextField(label: "Contact", controller: contactController),
            buildTextField(
              label: "Email",
              controller: emailController,
              enabled: false,
            ),
            if (isEditing)
              buildTextField(
                label: "Password",
                controller: passwordController,
                obscure: true,
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: isUpdating ? null : updateProfile,
                    borderRadius: BorderRadius.circular(10),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient:
                            isEditing
                                ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: [0.001, 1.0],
                                  colors: [
                                    Color(0xFF1A9C8C),
                                    Color.fromARGB(255, 2, 51, 164),
                                  ],
                                )
                                : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: const [0.001, 1.0],
                                  colors: [
                                    Colors.grey[400]!,
                                    Colors.grey[600]!,
                                  ],
                                ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: SizedBox(
                        height: 45,
                        child: Center(
                          child:
                              isUpdating
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(
                                    isEditing ? "Save Changes" : "Edit Profile",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                if (isEditing)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          fullNameController.text = userData?['fullName'] ?? '';
                          userNameController.text = userData?['userName'] ?? '';
                          contactController.text = userData?['contact'] ?? '';
                          isEditing = false;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: const SizedBox(
                          height: 45,
                          child: Center(
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
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
