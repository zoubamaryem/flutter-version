import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/book.dart';
import '../../core/providers/book_provider.dart';
import 'add_edit_book_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final String isbn;

  const BookDetailScreen({super.key, required this.isbn});

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editBook(context, bookProvider),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, bookProvider),
          ),
        ],
      ),
      body: FutureBuilder(
        future: bookProvider.fetchBook(isbn),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookProvider.status == BookStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading book details: ${bookProvider.errorMessage}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        bookProvider.resetError();
                        bookProvider.fetchBook(isbn);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final book = bookProvider.selectedBook;
          if (book == null) {
            return const Center(child: Text('Book not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookHeader(context, book),
                const SizedBox(height: 32),
                _buildInfoSection('ISBN', book.isbn),
                const Divider(),
                _buildInfoSection('Title', book.title),
                const Divider(),
                _buildInfoSection('Author', book.author),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookHeader(BuildContext context, Book book) {
    // Generate a deterministic color based on the book title
    final colors = [
      Colors.blue.shade200,
      Colors.green.shade200,
      Colors.purple.shade200,
      Colors.orange.shade200,
      Colors.teal.shade200,
    ];
    final colorIndex = book.title.hashCode % colors.length;
    final coverColor = colors[colorIndex];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Book cover
        Container(
          width: 120,
          height: 180,
          decoration: BoxDecoration(
            color: coverColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.book, size: 40),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    book.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Book details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'by ${book.author}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'ISBN: ${book.isbn}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  void _editBook(BuildContext context, BookProvider bookProvider) {
    final book = bookProvider.selectedBook;
    if (book != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddEditBookScreen(book: book),
        ),
      ).then((_) {
        // Refresh book details after returning from edit screen
        bookProvider.fetchBook(isbn);
      });
    }
  }

  void _confirmDelete(BuildContext context, BookProvider bookProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _deleteBook(context, bookProvider);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBook(BuildContext context, BookProvider bookProvider) async {
    final success = await bookProvider.deleteBook(isbn);
    
    if (success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Return to book list
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting book: ${bookProvider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}