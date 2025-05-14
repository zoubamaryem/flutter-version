class Book {
  final String isbn;
  final String title;
  final String author;

  Book({
    required this.isbn,
    required this.title,
    required this.author,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      isbn: json['isbn'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isbn': isbn,
      'title': title,
      'author': author,
    };
  }

  Book copyWith({
    String? isbn,
    String? title,
    String? author,
  }) {
    return Book(
      isbn: isbn ?? this.isbn,
      title: title ?? this.title,
      author: author ?? this.author,
    );
  }

  @override
  String toString() {
    return 'Book{isbn: $isbn, title: $title, author: $author}';
  }
}