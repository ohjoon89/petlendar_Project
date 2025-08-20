import 'dart:io';
import 'package:flutter/material.dart';
import 'pet_profile.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditPage extends StatefulWidget {
  final PetProfile? profile;

  const ProfileEditPage({super.key, this.profile});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _memoController = TextEditingController();
  String _profileImagePath = '';
  String _backgroundImagePath = '';
  String _selectedGender = 'male';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      _nameController.text = widget.profile!.name;
      _ageController.text = widget.profile!.age;
      _memoController.text = widget.profile!.memo;
      _profileImagePath = widget.profile!.profileImagePath;
      _backgroundImagePath = widget.profile!.backgroundImagePath;
      _selectedGender = widget.profile!.gender;
    }
  }

  // 성별 버튼 위젯
  Widget _genderButton(String gender, String emoji) {
    final bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 4),
            Text(
              gender == 'male' ? '남' : '여',
              style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    final profile = PetProfile(
      name: _nameController.text,
      age: _ageController.text,
      memo: _memoController.text,
      gender: _selectedGender,
      profileImagePath: _profileImagePath,
      backgroundImagePath: _backgroundImagePath,
    );
    Navigator.pop(context, profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("프로필 추가/수정"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // ✅ 배경 이미지
                GestureDetector(
                  onTap: () {
                    // 선택 다이얼로그 (사진첩 / 기본 이미지)
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.photo),
                            title: const Text("사진첩에서 추가"),
                            onTap: () async {
                              Navigator.pop(context);
                              final pickedFile =
                                  await _picker.pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                setState(() {
                                  _backgroundImagePath = pickedFile.path;
                                });
                              }
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.image),
                            title: const Text("기본 이미지"),
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _backgroundImagePath = ''; // 기본 이미지로 초기화
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: _backgroundImagePath.isNotEmpty
                      ? Image.file(
                          File(_backgroundImagePath),
                          height: MediaQuery.of(context).size.height * 0.4,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          color: Colors.grey[300],
                          child: const Center(child: Text("배경 사진 추가")),
                        ),
                ),

                // ✅ 프로필 사진
                Positioned(
                  bottom: -50,
                  child: GestureDetector(
                    onTap: () async {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo),
                              title: const Text("사진첩에서 추가"),
                              onTap: () async {
                                Navigator.pop(context);
                                final pickedFile =
                                    await _picker.pickImage(source: ImageSource.gallery);
                                if (pickedFile != null) {
                                  setState(() {
                                    _profileImagePath = pickedFile.path;
                                  });
                                }
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.person),
                              title: const Text("기본 이미지"),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _profileImagePath = ''; // 기본 아이콘으로 초기화
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImagePath.isNotEmpty
                          ? FileImage(File(_profileImagePath))
                          : null,
                      child: _profileImagePath.isEmpty
                          ? const Icon(Icons.pets, size: 50)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "이름"),
                  ),
                  TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: "나이"),
                  ),
                  TextField(
                    controller: _memoController,
                    decoration: const InputDecoration(labelText: "메모"),
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _genderButton('male', '♂️'),
                      const SizedBox(width: 12),
                      _genderButton('female', '♀️'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
