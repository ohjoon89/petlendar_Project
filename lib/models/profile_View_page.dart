import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_edit_page.dart';
import 'pet_profile.dart';
import '../main.dart';

class ProfileViewPage extends StatefulWidget {
  final int index;
  final PetProfile profile;

  const ProfileViewPage({super.key, required this.index, required this.profile});

  @override
  State<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  late PetProfile profile;

  @override
  void initState() {
    super.initState();
    profile = widget.profile;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PetProfileProvider>(context);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double backgroundHeight = screenHeight * 0.5;
    final double profileRadius = 70;

    return Scaffold(
      appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back), // 왼쪽 상단 닫기 버튼
    onPressed: () {
      Navigator.pop(context); // 상세보기 닫기
    },
  ),
  title: Text(profile.name),
  actions: [
    IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () async {
        final updatedProfile = await Navigator.push<PetProfile>(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileEditPage(profile: profile),
          ),
        );
        if (updatedProfile != null) {
          setState(() => profile = updatedProfile);
          final provider = Provider.of<PetProfileProvider>(context, listen: false);
          provider.updateProfile(widget.index, updatedProfile);
        }
      },
    ),
    IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () {
        final provider = Provider.of<PetProfileProvider>(context, listen: false);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("프로필 삭제"),
            content: const Text("정말 삭제하시겠습니까?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("취소"),
              ),
              TextButton(
                onPressed: () {
                  provider.deleteProfile(widget.index);
                  Navigator.pop(context); // 다이얼로그 닫기
                  Navigator.pop(context); // 상세보기 페이지 닫기
                },
                child: const Text("삭제", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    ),
  ],
),

      body: SingleChildScrollView(
        child: Stack(
          children: [
            // 배경 이미지
            SizedBox(
              height: backgroundHeight,
              width: double.infinity,
              child: profile.backgroundImagePath.isNotEmpty
                  ? Image.file(
                      File(profile.backgroundImagePath),
                      fit: BoxFit.cover,
                    )
                  : Container(color: Colors.grey[300]),
            ),
            // 프로필 사진 + 이름
            Positioned(
              top: backgroundHeight - profileRadius,
              left: screenWidth / 2 - profileRadius,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: profileRadius,
                        backgroundImage: profile.profileImagePath.isNotEmpty
                            ? FileImage(File(profile.profileImagePath))
                            : null,
                        child: profile.profileImagePath.isEmpty
                            ? const Icon(Icons.pets, size: 50)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Icon(
                          profile.gender == 'male' ? Icons.male : Icons.female,
                          color: profile.gender == 'male' ? Colors.blue : Colors.pink,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // 나이 + 메모 내용
            Padding(
              padding: EdgeInsets.only(
                top: backgroundHeight + profileRadius + 32,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "나이: ${profile.age}살",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.memo,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(PetProfileProvider provider, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("프로필 삭제"),
        content: const Text("정말 삭제하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () {
              provider.deleteProfile(index);
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 상세보기 닫기
            },
            child: const Text("삭제", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}