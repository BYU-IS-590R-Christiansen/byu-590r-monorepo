import 'package:flutter/material.dart';
import 'package:byu_590r_flutter_app/core/api_client.dart';
import 'package:byu_590r_flutter_app/models/book.dart';

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
          return const Center(child: Text('No books returned.'));
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
    if (widget.embedded) {
      return Column(
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
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
      ),
      body: _booksBody(),
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
