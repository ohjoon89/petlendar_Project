class PhotoItem {
  final String filePath;
  final DateTime createdAt;

  PhotoItem({required this.filePath, required this.createdAt});

  factory PhotoItem.fromJson(Map<String, dynamic> json) => PhotoItem(
        filePath: json['filePath'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'filePath': filePath,
        'createdAt': createdAt.toIso8601String(),
      };
}
