import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:my_app/Screens/Loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool isDataLoaded = false;
  bool isPasswordVisible = false;
  File? profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');
      final String? token = prefs.getString('auth_token');

      if (userId == null || token == null) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated!')),
        );
        return;
      }

      // Call the GetUser API
      final response = await http.get(
        Uri.parse('https://lokate.bsite.net/api/user/GetUser?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        setState(() {
          fullNameController.text = responseData['fullName'] ?? '';
          userNameController.text = responseData['userName'] ?? '';
          contactController.text = responseData['contact'] ?? '';
          emailController.text = responseData['email'] ?? '';
          isLoading = false;
          isDataLoaded = true;
        });

        await prefs.setString('fullname', fullNameController.text);
        await prefs.setString('username', userNameController.text);
        await prefs.setString('contact', contactController.text);
        await prefs.setString('email', emailController.text);
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load user data: ${response.reasonPhrase}'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load user data: $e')));
    }
  }

  void handleLogout() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Loginscreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleSaveChanges() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');
      final String? token = prefs.getString('auth_token');

      if (userId == null || token == null) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated!')),
        );
        return;
      }

      final Map<String, dynamic> requestData = {
        'UserId': userId,
        'FullName': fullNameController.text.trim(),
        'UserName': userNameController.text.trim(),
        'Contact': contactController.text.trim(),
      };

      final response = await http.post(
        Uri.parse('https://lokate.bsite.net/api/user/UpdateProfile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          await prefs.setString('fullname', fullNameController.text);
          await prefs.setString('username', userNameController.text);
          await prefs.setString('contact', contactController.text);

          setState(() {
            isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['message'] ?? 'Profile updated successfully!',
              ),
            ),
          );
        } else {
          setState(() {
            isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['message'] ?? 'Failed to update profile!',
              ),
            ),
          );
        }
      } else if (response.statusCode == 404) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not found!')));
      } else {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${response.reasonPhrase}'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
    } finally {
      Navigator.pop(context);
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
    bool isPasswordField = false,
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
            obscureText: isPasswordField ? !isPasswordVisible : obscure,
            enabled: enabled,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.withOpacity(0.1),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              suffixIcon:
                  isPasswordField
                      ? IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      )
                      : null,
            ),
            style: TextStyle(
              color: enabled ? Colors.black87 : Colors.grey,
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
    final screenWidth = MediaQuery.of(context).size.width;

    if (isLoading) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    final content = Padding(
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
                        profileImage != null ? FileImage(profileImage!) : null,
                    child:
                        profileImage == null
                            ? Icon(
                              Icons.person,
                              size: screenWidth * 0.28,
                              color: Colors.grey[700],
                            )
                            : null,
                  ),
                ),
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
          buildTextField(
            label: "Username",
            controller: userNameController,
            enabled: true,
          ),
          buildTextField(
            label: "Contact",
            controller: contactController,
            enabled: true,
          ),
          buildTextField(
            label: "Email",
            controller: emailController,
            enabled: false,
          ),
          // buildTextField(
          //   label: "Password",
          //   controller: passwordController,
          //   isPasswordField: true,
          //   enabled: false,
          // ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: handleSaveChanges,
                  borderRadius: BorderRadius.circular(10),
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.001, 1.0],
                        colors: [
                          Color(0xFF1A9C8C),
                          Color.fromARGB(255, 2, 51, 164),
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: const SizedBox(
                      height: 45,
                      child: Center(
                        child: Text(
                          "Update Profile",
                          style: TextStyle(
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
              Expanded(
                child: InkWell(
                  onTap: handleLogout,
                  borderRadius: BorderRadius.circular(10),
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.001, 1.0],
                        colors: [
                          Color(0xFF1A9C8C),
                          Color.fromARGB(255, 2, 51, 164),
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: SizedBox(
                      height: 45,
                      child: Center(
                        child:
                            isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  "Log out",
                                  style: TextStyle(
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
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        minimum: const EdgeInsets.all(0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return constraints.maxHeight < 700
                ? SingleChildScrollView(child: content)
                : content;
          },
        ),
      ),
    );
  }
}
