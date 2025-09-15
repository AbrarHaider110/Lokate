import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/Screens/Bottom_bar_navigation.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _controller = TextEditingController();
  bool isButtonEnabled = false;
  String? currentLocation;
  File? selectedImage;
  File? selectedVideo;
  File? selectedFile;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        isButtonEnabled = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    Position position = await Geolocator.getCurrentPosition();

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          currentLocation = "${place.locality}, ${place.country}";
        });
      }
    } catch (e) {
      setState(() {
        currentLocation = "Unknown";
      });
    }
  }

  void _openMediaOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Capture Photo"),
                onTap: () async {
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      selectedImage = File(pickedFile.path);
                      selectedVideo = null;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text("Record Video"),
                onTap: () async {
                  final pickedVideo = await ImagePicker().pickVideo(
                    source: ImageSource.camera,
                  );
                  if (pickedVideo != null) {
                    setState(() {
                      selectedVideo = File(pickedVideo.path);
                      selectedImage = null;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Pick from Gallery"),
                onTap: () async {
                  final pickedFile = await ImagePicker().pickMedia();

                  if (pickedFile != null) {
                    String path = pickedFile.path;
                    File picked = File(path);

                    if (path.endsWith('.mp4') ||
                        path.endsWith('.mov') ||
                        path.endsWith('.avi')) {
                      setState(() {
                        selectedVideo = picked;
                        selectedImage = null;
                      });
                    } else {
                      setState(() {
                        selectedImage = picked;
                        selectedVideo = null;
                      });
                    }
                  }

                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  void _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'ppt', 'doc', 'zip'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _openEmojiPicker() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            content: Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  [
                    "😊",
                    "😂",
                    "😍",
                    "😎",
                    "😭",
                    "🤔",
                    "🙌",
                    "🔥",
                    "💯",
                    "😡",
                    "😴",
                    "🎉",
                    "😅",
                    "😉",
                    "😇",
                    "🤩",
                    "😜",
                    "😒",
                    "🤐",
                    "🥳",
                    "👀",
                    "😤",
                  ].map((emoji) {
                    return GestureDetector(
                      onTap: () {
                        _controller.text += emoji;
                        Navigator.pop(context);
                      },
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    );
                  }).toList(),
            ),
          ),
    );
  }

  void _handlePost() {
    if (isButtonEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Post submitted")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomBarNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isPortrait =
                MediaQuery.of(context).orientation == Orientation.portrait;
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: isPortrait ? constraints.maxWidth * 0.9 : 600,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Create Post",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BottomBarNavigation(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              backgroundImage: NetworkImage(
                                "https://i.pravatar.cc/100?img=12",
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Your Name",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                if (currentLocation != null)
                                  GestureDetector(
                                    onTap: _getCurrentLocation,
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            currentLocation!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _controller,
                          maxLines: null,
                          decoration: const InputDecoration.collapsed(
                            hintText: "What's on your mind?",
                          ),
                        ),
                        if (selectedImage != null) ...[
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(selectedImage!),
                          ),
                        ],
                        if (selectedVideo != null) ...[
                          const SizedBox(height: 16),
                          const Text("Video selected"),
                        ],
                        if (selectedFile != null) ...[
                          const SizedBox(height: 16),
                          Text("File: ${selectedFile!.path.split('/').last}"),
                        ],
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.image,
                                  color: Colors.green,
                                ),
                                onPressed: _openMediaOptions,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.attach_file,
                                  color: Colors.blueGrey,
                                ),
                                onPressed: _uploadFile,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                ),
                                onPressed: _getCurrentLocation,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.emoji_emotions,
                                  color: Colors.orange,
                                ),
                                onPressed: _openEmojiPicker,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: GestureDetector(
                            onTap: isButtonEnabled ? _handlePost : null,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient:
                                    isButtonEnabled
                                        ? const LinearGradient(
                                          colors: [
                                            Color(0xFF1A9C8C),
                                            Color.fromARGB(255, 2, 51, 164),
                                          ],
                                        )
                                        : null,
                                color:
                                    isButtonEnabled
                                        ? null
                                        : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Post",
                                style: TextStyle(
                                  color:
                                      isButtonEnabled
                                          ? Colors.white
                                          : Colors.grey,
                                  fontWeight: FontWeight.bold,
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
            );
          },
        ),
      ),
    );
  }
}
