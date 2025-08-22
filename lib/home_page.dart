import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/profile_edit_page.dart';
import 'models/pet_profile.dart';
import 'main.dart';

// ✅ 전역 변수로 선택된 프로필 저장
PetProfile? lastSelectedProfile;
int? lastSelectedIndex;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PetProfile? _selectedProfile; // 선택된 프로필
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    // ✅ 화면 열릴 때 전역 변수에서 복원
    _selectedProfile = lastSelectedProfile;
    _selectedIndex = lastSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PetProfileProvider>(context);

    // ✅ 프로필 삭제된 경우 index 확인 후 초기화
    if (_selectedIndex != null &&
        (_selectedIndex! >= provider.profiles.length ||
            provider.profiles[_selectedIndex!] != _selectedProfile)) {
      _selectedProfile = null;
      _selectedIndex = null;
      lastSelectedProfile = null;
      lastSelectedIndex = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("홈"),
        leading: _selectedProfile != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedProfile = null;
                    _selectedIndex = null;
                    lastSelectedProfile = null;
                    lastSelectedIndex = null;
                  });
                },
              )
            : null,
        actions: _selectedProfile != null
            ? [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    if (_selectedIndex != null) {
                      final updatedProfile =
                          await Navigator.push<PetProfile>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProfileEditPage(profile: _selectedProfile),
                        ),
                      );
                      if (updatedProfile != null) {
                        provider.updateProfile(
                            _selectedIndex!, updatedProfile);
                        setState(() {
                          _selectedProfile = updatedProfile;
                          lastSelectedProfile = updatedProfile; // ✅ 복원용
                        });
                      }
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    if (_selectedIndex != null) {
                      _showDeleteDialog(provider, _selectedIndex!);
                    }
                  },
                ),
              ]
            : provider.profiles.isNotEmpty
                ? [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.blue),
                          onPressed: () async {
                            final newProfile =
                                await Navigator.push<PetProfile>(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ProfileEditPage()),
                            );
                            if (newProfile != null) {
                              provider.addProfile(newProfile);
                            }
                          },
                        ),
                      ),
                    ),
                  ]
                : [],
      ),
      body: _selectedProfile == null
          ? _buildProfileList(provider)
          : _buildProfileDetail(provider),
    );
  }

  Widget _buildProfileList(PetProfileProvider provider) {
    if (provider.profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 120, color: Colors.grey),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final newProfile = await Navigator.push<PetProfile>(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileEditPage()),
                );
                if (newProfile != null) {
                  provider.addProfile(newProfile);
                }
              },
              child: const Text("프로필 추가"),
            ),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = 300.0;
    final profileRadius = 50.0;

    return ListView.builder(
      itemCount: provider.profiles.length,
      itemBuilder: (context, index) {
        final profile = provider.profiles[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedProfile = profile;
              _selectedIndex = index;
              lastSelectedProfile = profile; // ✅ 전역 변수에 저장
              lastSelectedIndex = index;
            });
          },
          onLongPress: () {
            _showDeleteDialog(provider, index);
          },
          child: Card(
            margin: const EdgeInsets.all(12),
            child: SizedBox(
              height: cardHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    height: cardHeight * 0.5,
                    width: double.infinity,
                    child: profile.backgroundImagePath.isNotEmpty
                        ? Image.file(File(profile.backgroundImagePath),
                            fit: BoxFit.cover)
                        : Container(color: Colors.grey[300]),
                  ),
                  Positioned(
                    top: cardHeight * 0.5 - profileRadius,
                    left: screenWidth / 2 - profileRadius,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: profileRadius,
                          backgroundImage:
                              profile.profileImagePath.isNotEmpty
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
                            profile.gender == 'male'
                                ? Icons.male
                                : Icons.female,
                            color: profile.gender == 'male'
                                ? Colors.blue
                                : Colors.pink,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.name,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("나이: ${profile.age}살",
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 2),
                        Text(profile.memo,
                            style: const TextStyle(fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileDetail(PetProfileProvider provider) {
    if (_selectedProfile == null || _selectedIndex == null) {
      return const SizedBox();
    }

    final profile = _selectedProfile!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final backgroundHeight = screenHeight * 0.5;
    final profileRadius = 70.0;

    return SingleChildScrollView(
      child: Stack(
        children: [
          SizedBox(
            height: backgroundHeight,
            width: double.infinity,
            child: profile.backgroundImagePath.isNotEmpty
                ? Image.file(File(profile.backgroundImagePath),
                    fit: BoxFit.cover)
                : Container(color: Colors.grey[300]),
          ),
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
                        profile.gender == 'male'
                            ? Icons.male
                            : Icons.female,
                        color: profile.gender == 'male'
                            ? Colors.blue
                            : Colors.pink,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(profile.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: backgroundHeight + profileRadius + 32,
                left: 16,
                right: 16,
                bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("나이: ${profile.age}살",
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text(profile.memo, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
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
              child: const Text("취소")),
          TextButton(
            onPressed: () {
              provider.deleteProfile(index);
              Navigator.pop(context);
              setState(() {
                _selectedProfile = null;
                _selectedIndex = null;
                lastSelectedProfile = null;
                lastSelectedIndex = null;
              });
            },
            child: const Text("삭제", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}