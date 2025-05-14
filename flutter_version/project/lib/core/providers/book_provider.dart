import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../services/api_service.dart';

enum BookStatus { initial, loading, loaded, error }

class BookProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Book> _books = [];
  Book? _selectedBook;
  String _errorMessage = '';
  BookStatus _status = BookStatus.initial;

  // Getters
  List<Book> get books => _books;
  Book? get selectedBook => _selectedBook;
  String get errorMessage => _errorMessage;
  BookStatus get status => _status;
  bool get isLoading => _status == BookStatus.loading;

  // Fetch all books
  Future<void> fetchBooks() async {
    _status = BookStatus.loading;
    notifyListeners();

    try {
      _books = await _apiService.getBooks();
      _status = BookStatus.loaded;
    } catch (e) {
      _status = BookStatus.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }

  // Fetch a single book
  Future<void> fetchBook(String isbn) async {
    _status = BookStatus.loading;
    notifyListeners();

    try {
      _selectedBook = await _apiService.getBook(isbn);
      _status = BookStatus.loaded;
    } catch (e) {
      _status = BookStatus.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }

  // Create a new book
  Future<bool> createBook(Book book) async {
    _status = BookStatus.loading;
    notifyListeners();

    try {
      final newBook = await _apiService.createBook(book);
      _books.add(newBook);
      _status = BookStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = BookStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update an existing book
  Future<bool> updateBook(Book book) async {
    _status = BookStatus.loading;
    notifyListeners();

    try {
      final updatedBook = await _apiService.updateBook(book);
      final index = _books.indexWhere((b) => b.isbn == book.isbn);
      
      if (index != -1) {
        _books[index] = updatedBook;
      }
      
      _status = BookStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = BookStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete a book
  Future<bool> deleteBook(String isbn) async {
    _status = BookStatus.loading;
    notifyListeners();

    try {
      await _apiService.deleteBook(isbn);
      _books.removeWhere((book) => book.isbn == isbn);
      _status = BookStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = BookStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Search books by title or author
  List<Book> searchBooks(String query) {
    if (query.isEmpty) {
      return _books;
    }
    
    final lowerCaseQuery = query.toLowerCase();
    return _books.where((book) {
      return book.title.toLowerCase().contains(lowerCaseQuery) || 
             book.author.toLowerCase().contains(lowerCaseQuery);
    }).toList();
  }

  // Clear any selected book
  void clearSelectedBook() {
    _selectedBook = null;
    notifyListeners();
  }

  // Reset any error state
  void resetError() {
    _errorMessage = '';
    _status = _books.isEmpty ? BookStatus.initial : BookStatus.loaded;
    notifyListeners();
  }
}