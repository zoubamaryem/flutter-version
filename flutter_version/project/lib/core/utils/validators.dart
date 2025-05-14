class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  static String? validateIsbn(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ISBN is required';
    }
    
    // Remove hyphens and spaces for validation
    final cleanIsbn = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check for ISBN-10 or ISBN-13 format
    if (cleanIsbn.length != 10 && cleanIsbn.length != 13) {
      return 'ISBN must be 10 or 13 characters long';
    }
    
    // Check if all characters are digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanIsbn)) {
      return 'ISBN can only contain numbers';
    }
    
    return null;
  }
  
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    return null;
  }
}