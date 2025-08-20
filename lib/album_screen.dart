import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'dart:convert';

import 'models/photo_item.dart';


class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  List<PhotoItem> photoList = [];
  bool _isPicking = false;
  bool _isSelectionMode = false;
  Set<int> _selectedForAction = {};

  @override
  void initState() {
    super.initState();
    _initializePhotos();
  }

  Future<void> _initializePhotos() async {
    photoList = await loadPhotoList();
    setState(() {
      _selectedImages = photoList.map((p) => XFile(p.filePath)).toList();
    });
  }

  /// 파일 관리
  Future<String> getPhotosDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${directory.path}/photos');
    if (!photosDir.existsSync()) photosDir.createSync();
    return photosDir.path;
  }

  Future<File> getPhotoListFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/photos.json');
  }

  Future<void> savePhotoList(List<PhotoItem> photoList) async {
    final file = await getPhotoListFile();
    final jsonStr = jsonEncode(photoList.map((p) => p.toJson()).toList());
    await file.writeAsString(jsonStr);
  }

  Future<List<PhotoItem>> loadPhotoList() async {
    final file = await getPhotoListFile();
    if (await file.exists()) {
      final jsonStr = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((json) => PhotoItem.fromJson(json)).toList();
    }
    return [];
  }

  /// 사진 선택
  Future<void> _pickImages() async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        final photosDirPath = await getPhotosDirectory();
        final photosDir = Directory(photosDirPath);

        for (var pickedFile in pickedFiles) {
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
          final savedFile =
              await File(pickedFile.path).copy('${photosDir.path}/$fileName');

          final newPhoto =
              PhotoItem(filePath: savedFile.path, createdAt: DateTime.now());
          photoList.add(newPhoto);
          _selectedImages.add(XFile(savedFile.path));
        }

        await savePhotoList(photoList);
        setState(() {});
      }
    } catch (e) {
      print("Error picking images: $e");
    } finally {
      _isPicking = false;
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedForAction.clear();
    });
  }

  void _selectForAction(int index) {
    setState(() {
      if (_selectedForAction.contains(index)) {
        _selectedForAction.remove(index);
      } else {
        _selectedForAction.add(index);
      }
    });
  }

  void _deleteSelectedImages() {
    setState(() {
      for (var index
          in _selectedForAction.toList()..sort((a, b) => b.compareTo(a))) {
        final file = File(_selectedImages[index].path);
        if (file.existsSync()) file.deleteSync();
        _selectedImages.removeAt(index);
        photoList.removeAt(index);
      }
      savePhotoList(photoList);
      _isSelectionMode = false;
      _selectedForAction.clear();
    });
  }

  void _shareSelectedImages() async {
    if (_selectedForAction.isEmpty) return;

    List<XFile> filesToShare =
        _selectedForAction.map((i) => _selectedImages[i]).toList();

    await Share.shareXFiles(
      filesToShare,
      text: '공유할 사진입니다.',
    );
  }

  void _viewImageFullScreen(XFile image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("사진 보기")),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(File(image.path)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!_isSelectionMode) ...[
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add),
                  label: const Text("추가"),
                ),
                const SizedBox(width: 8),
              ],
              ElevatedButton.icon(
                onPressed: _toggleSelectionMode,
                icon: const Icon(Icons.select_all),
                label: Text(_isSelectionMode ? "취소" : "선택"),
              ),
              const SizedBox(width: 8),
              if (_isSelectionMode) ...[
                ElevatedButton.icon(
                  onPressed:
                      _selectedForAction.isEmpty ? null : _deleteSelectedImages,
                  icon: const Icon(Icons.delete),
                  label: const Text("삭제"),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed:
                      _selectedForAction.isEmpty ? null : _shareSelectedImages,
                  icon: const Icon(Icons.share),
                  label: const Text("공유"),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: _selectedImages.isEmpty
              ? const Center(
                  child: Text("사진을 선택해주세요",
                      style: TextStyle(fontSize: 20)),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ReorderableGridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    children: List.generate(
                      _selectedImages.length,
                      (index) {
                        bool isSelected = _selectedForAction.contains(index);
                        return GestureDetector(
                          key: ValueKey(_selectedImages[index].path),
                          onTap: () {
                            if (_isSelectionMode) {
                              _selectForAction(index);
                            } else {
                              _viewImageFullScreen(_selectedImages[index]);
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: isSelected
                                      ? Border.all(color: Colors.red, width: 3)
                                      : null,
                                ),
                                child: Image.file(
                                  File(_selectedImages[index].path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              if (_isSelectionMode)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        final image = _selectedImages.removeAt(oldIndex);
                        _selectedImages.insert(newIndex, image);

                        final photo = photoList.removeAt(oldIndex);
                        photoList.insert(newIndex, photo);

                        savePhotoList(photoList);
                      });
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
