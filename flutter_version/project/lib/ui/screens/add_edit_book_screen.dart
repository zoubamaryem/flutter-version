import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/book.dart';
import '../../core/providers/book_provider.dart';

class AddEditBookScreen extends StatefulWidget {
  final Book? book;

  const AddEditBookScreen({super.key, this.book});

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _isbnController = TextEditingController();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  bool _isEditing = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.book != null;
    
    if (_isEditing) {
      _isbnController.text = widget.book!.isbn;
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
    }
  }

  @override
  void dispose() {
    _isbnController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Book' : 'Add New Book'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBookCoverPlaceholder(),
              const SizedBox(height: 24),
              TextFormField(
                controller: _isbnController,
                decoration: const InputDecoration(
                  labelText: 'ISBN',
                  hintText: 'Enter the book\'s ISBN',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                enabled: !_isEditing, // ISBN can't be edited once created
                validator: _validateIsbn,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter the book\'s title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: _validateTitle,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  hintText: 'Enter the book\'s author',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: _validateAuthor,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : Text(_isEditing ? 'Update Book' : 'Add Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookCoverPlaceholder() {
    final colors = [
      Colors.blue.shade200,
      Colors.green.shade200,
      Colors.purple.shade200,
      Colors.orange.shade200,
      Colors.teal.shade200,
    ];
    
    // Use a deterministic color based on title or ISBN
    final colorIndex = _isEditing
        ? widget.book!.title.hashCode % colors.length
        : DateTime.now().millisecondsSinceEpoch % colors.length;
    
    final coverColor = colors[colorIndex];
    
    return Center(
      child: Container(
        width: 150,
        height: 200,
        decoration: BoxDecoration(
          color: coverColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.book, size: 50),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _isEditing ? widget.book!.title : 'New Book',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.book!.author,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateIsbn(String? value) {
    if (value == null || value.isEmpty) {
      return 'ISBN is required';
    }
    if (value.length < 10) {
      return 'ISBN should be at least 10 characters';
    }
    return null;
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    return null;
  }

  String? _validateAuthor(String? value) {
    if (value == null || value.isEmpty) {
      return 'Author is required';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      final book = Book(
        isbn: _isbnController.text,
        title: _titleController.text,
        author: _authorController.text,
      );

      bool success;
      if (_isEditing) {
        success = await bookProvider.updateBook(book);
      } else {
        success = await bookProvider.createBook(book);
      }

      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing
                  ? 'Book updated successfully!'
                  : 'Book added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(bookProvider.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}