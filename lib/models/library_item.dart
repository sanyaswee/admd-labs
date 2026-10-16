import 'user.dart';

abstract class LibraryItem {
  String title;
  String? author;
  DateTime? publishDate;
  User? borrower;
  DateTime? dueDate;

  LibraryItem({
    required this.title,
    this.author,
    this.publishDate,
    this.borrower,
    this.dueDate,
  });
}

class Book extends LibraryItem {
  int? pageCount;
  String? isbn;

  Book({
    required super.title,
    super.author,
    super.publishDate,
    super.borrower,
    super.dueDate,
    this.pageCount,
    this.isbn,
  });
}

class Magazine extends LibraryItem {
  String? issueNumber;
  String? publisher;

  Magazine({
    required super.title,
    super.author,
    super.publishDate,
    super.borrower,
    super.dueDate,
    this.issueNumber,
    this.publisher,
  });
}

class Library {
  final List<LibraryItem> _items = [];

  List<LibraryItem> get items => _items;

  bool addItem(LibraryItem item) {
    if (item.title.trim().isEmpty) {
      return false; // Invalid item
    }
    _items.add(item);
    return true;
  }

  List<LibraryItem> searchByTitle(String? query) {
    if (query == null || query.trim().isEmpty) {
      return [];
    }
    final lowerQuery = query.toLowerCase();
    return _items.where((item) => item.title.toLowerCase().contains(lowerQuery)).toList();
  }

  List<LibraryItem> getItemsByAuthor(String? author) {
    if (author == null || author.trim().isEmpty) {
      return [];
    }
    final lowerAuthor = author.toLowerCase();
    return _items.where((item) {
      final itemAuthor = item.author;
      if (itemAuthor == null) return false;
      return itemAuthor.toLowerCase() == lowerAuthor;
    }).toList();
  }

  List<LibraryItem> getRecentItems() {
    final recent = _items.where((item) => item.publishDate != null).toList();
    recent.sort((a, b) => b.publishDate!.compareTo(a.publishDate!));
    return recent;
  }

  bool borrowItem(LibraryItem item, User user, DateTime dueDate) {
    if (item.borrower != null) {
      return false; // Already borrowed
    }
    item.borrower = user;
    item.dueDate = dueDate;
    return true;
  }

  bool returnItem(LibraryItem item) {
    if (item.borrower == null) {
      return false; // Not borrowed
    }
    item.borrower = null;
    item.dueDate = null;
    return true;
  }
}
