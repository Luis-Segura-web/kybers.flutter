/// Category model for organizing channels
class Category {
  final String id;
  final String name;
  final String? parentId;

  const Category({
    required this.id,
    required this.name,
    this.parentId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['category_id']?.toString() ?? '',
      name: json['category_name'] ?? '',
      parentId: json['parent_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': id,
      'category_name': name,
      'parent_id': parentId,
    };
  }
}