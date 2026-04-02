import 'package:flutter/material.dart';
import 'package:byu_590r_flutter_app/core/api_client.dart';
import 'package:byu_590r_flutter_app/models/book.dart';
import 'package:byu_590r_flutter_app/models/genre_option.dart';
import 'package:byu_590r_flutter_app/screens/book_form_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({
    super.key,
    required this.accessToken,
    this.embedded = false,
  });

  final String accessToken;
  final bool embedded;

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final ApiClient _apiClient = ApiClient();
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _loadBooks();
  }

  Future<List<Book>> _loadBooks() async {
    final dynamic res = await _apiClient.getBooks(widget.accessToken);
    if (res is! Map<String, dynamic>) return [];
    if (res['success'] != true) {
      throw Exception(res['message']?.toString() ?? 'Could not load books');
    }
    final raw = res['results'];
    if (raw is! List<dynamic>) return [];
    return raw
        .map((e) => Book.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _retry() async {
    setState(() {
      _booksFuture = _loadBooks();
    });
  }

  Future<void> _openAddBook() async {
    final books = await _loadBooks();
    if (!mounted) return;
    final genres = genresForForm(books);
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => BookFormScreen(
          accessToken: widget.accessToken,
          genres: genres,
        ),
      ),
    );
    if (ok == true && mounted) _retry();
  }

  Future<void> _openEditBook(Book book) async {
    final books = await _loadBooks();
    if (!mounted) return;
    final genres = genresForForm(books, ensureGenreFor: book);
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => BookFormScreen(
          accessToken: widget.accessToken,
          genres: genres,
          book: book,
        ),
      ),
    );
    if (ok == true && mounted) _retry();
  }

  Future<void> _confirmDelete(Book book) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete book?'),
        content: Text('Remove “${book.name}” from the catalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final dynamic res = await _apiClient.deleteBook(
      accessToken: widget.accessToken,
      id: book.id,
    );
    if (!mounted) return;

    if (res is Map<String, dynamic> && res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book deleted')),
      );
      _retry();
    } else {
      final msg = res is Map<String, dynamic>
          ? (res['message']?.toString() ?? 'Delete failed')
          : 'Delete failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  static const double _coverWidth = 56;
  static const double _coverHeight = 72;

  Widget _bookCoverLeading(Book book) {
    Widget placeholder() {
      return Container(
        width: _coverWidth,
        height: _coverHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.menu_book_outlined,
          size: 32,
          color: Theme.of(context).colorScheme.outline,
        ),
      );
    }

    final url = book.imageUrl;
    if (url == null || url.isEmpty) {
      return placeholder();
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openCoverFullScreen(context, url),
        borderRadius: BorderRadius.circular(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            url,
            width: _coverWidth,
            height: _coverHeight,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                width: _coverWidth,
                height: _coverHeight,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => placeholder(),
          ),
        ),
      ),
    );
  }

  void _openCoverFullScreen(BuildContext context, String imageUrl) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => _BookCoverFullScreenPage(imageUrl: imageUrl),
      ),
    );
  }

  Widget _booksBody() {
    return FutureBuilder<List<Book>>(
      future: _booksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _retry,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        final books = snapshot.data ?? [];
        if (books.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No books yet. Tap + Add book to create one.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            final future = _loadBooks();
            setState(() => _booksFuture = future);
            await future;
          },
          child: ListView.separated(
            padding: widget.embedded
                ? const EdgeInsets.only(bottom: 16)
                : null,
            itemCount: books.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final book = books[index];
              final authors = book.authorNames.isEmpty
                  ? '—'
                  : book.authorNames.join(', ');
              return ListTile(
                leading: _bookCoverLeading(book),
                title: Text(
                  book.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') _openEditBook(book);
                    if (value == 'delete') _confirmDelete(book);
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(book.description),
                    const SizedBox(height: 4),
                    Text(
                      'Authors: $authors',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (book.genreName != null)
                      Text(
                        'Genre: ${book.genreName}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (book.inventoryTotalQty != null)
                      Text(
                        'Inventory: ${book.checkedQty ?? 0} / ${book.inventoryTotalQty}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
                isThreeLine: true,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fab = FloatingActionButton.extended(
      onPressed: _openAddBook,
      icon: const Icon(Icons.add),
      label: const Text('Add book'),
    );

    if (widget.embedded) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                'Catalog',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Expanded(child: _booksBody()),
          ],
        ),
        floatingActionButton: fab,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
      ),
      body: _booksBody(),
      floatingActionButton: fab,
    );
  }
}

class _BookCoverFullScreenPage extends StatelessWidget {
  const _BookCoverFullScreenPage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  width: 120,
                  height: 120,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Could not load image.',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
