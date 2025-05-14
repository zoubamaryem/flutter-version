import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/book_provider.dart';
import '../widgets/book_list.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import 'add_edit_book_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookProvider>(context, listen: false).fetchBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bookshelf',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              _showThemeDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title or author...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => 
                Provider.of<BookProvider>(context, listen: false).fetchBooks(),
              child: Consumer<BookProvider>(
                builder: (context, bookProvider, child) {
                  if (bookProvider.isLoading && bookProvider.books.isEmpty) {
                    return const LoadingView();
                  }
                  
                  if (bookProvider.status == BookStatus.error) {
                    return ErrorView(
                      errorMessage: bookProvider.errorMessage,
                      onRetry: () {
                        bookProvider.resetError();
                        bookProvider.fetchBooks();
                      },
                    );
                  }
                  
                  final filteredBooks = bookProvider.searchBooks(_searchQuery);
                  
                  if (filteredBooks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No books found. Add your first book!'
                                : 'No books match your search.',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return BookList(books: filteredBooks);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditBookScreen(),
            ),
          ).then((_) {
            // Refresh book list after returning from add/edit screen
            Provider.of<BookProvider>(context, listen: false).fetchBooks();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('System Default'),
                leading: const Icon(Icons.brightness_auto),
                onTap: () {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Light'),
                leading: const Icon(Icons.brightness_5),
                onTap: () {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Dark'),
                leading: const Icon(Icons.brightness_4),
                onTap: () {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}