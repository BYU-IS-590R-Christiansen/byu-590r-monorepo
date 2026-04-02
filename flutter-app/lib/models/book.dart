/// Book row from `GET /api/books` (`results` array items).
class Book {
  Book({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.genreId,
    this.genreName,
    required this.authorNames,
    this.inventoryTotalQty,
    this.checkedQty,
  });

  final int id;
  final String name;
  final String description;
  /// Cover image URL from API `file` (null when no image).
  final String? imageUrl;
  final int? genreId;
  final String? genreName;
  final List<String> authorNames;
  final int? inventoryTotalQty;
  final int? checkedQty;

  factory Book.fromJson(Map<String, dynamic> json) {
    final genre = json['genre'] as Map<String, dynamic>?;
    final authors = json['authors'] as List<dynamic>? ?? [];
    final names = <String>[];
    for (final a in authors) {
      if (a is! Map<String, dynamic>) continue;
      final first = a['first_name'] as String? ?? '';
      final last = a['last_name'] as String? ?? '';
      final combined = '$first $last'.trim();
      if (combined.isNotEmpty) names.add(combined);
    }
    final rawFile = json['file'];
    String? imageUrl;
    if (rawFile is String && rawFile.trim().isNotEmpty) {
      imageUrl = rawFile.trim();
    }

    final gid = (json['genre_id'] as num?)?.toInt() ??
        ((genre?['id'] as num?)?.toInt());

    return Book(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: imageUrl,
      genreId: gid,
      genreName: genre?['name'] as String?,
      authorNames: names,
      inventoryTotalQty: (json['inventory_total_qty'] as num?)?.toInt(),
      checkedQty: (json['checked_qty'] as num?)?.toInt(),
    );
  }
}
