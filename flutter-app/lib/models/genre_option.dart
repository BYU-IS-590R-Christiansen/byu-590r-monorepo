import 'package:byu_590r_flutter_app/models/book.dart';

/// Selectable genre for book forms (ids align with `GenreSeeder` when DB is seeded).
class GenreOption {
  const GenreOption(this.id, this.name);

  final int id;
  final String name;
}

/// Build genres from loaded books; if none, use default seed ids/names.
/// [ensureGenreFor] adds that book's genre so edit forms always include it.
List<GenreOption> genresForForm(
  List<Book> books, {
  Book? ensureGenreFor,
}) {
  final map = <int, String>{};
  for (final b in books) {
    final id = b.genreId;
    final name = b.genreName;
    if (id != null && name != null && name.isNotEmpty) {
      map[id] = name;
    }
  }
  final ensure = ensureGenreFor;
  if (ensure != null) {
    final id = ensure.genreId;
    final name = ensure.genreName;
    if (id != null && name != null && name.isNotEmpty) {
      map[id] = name;
    }
  }
  if (map.isEmpty) {
    return const [
      GenreOption(1, 'Fantasy'),
      GenreOption(2, 'Sci-Fi'),
      GenreOption(3, 'Romance'),
      GenreOption(4, 'Religion'),
    ];
  }
  final list = map.entries.map((e) => GenreOption(e.key, e.value)).toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  return list;
}
