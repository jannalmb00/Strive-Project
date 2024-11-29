class Quote {
  final String quoteText;
  final String author;
  final String? imageUrl;  // Make imageUrl nullable, in case it's missing
  final int? characterCount;
  final String htmlFormat;

  Quote({
    required this.quoteText,
    required this.author,
    this.imageUrl,  // Allow for null value
    required this.characterCount,
    required this.htmlFormat,
  });

  // Factory constructor to create a Quote object from JSON data
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      quoteText: json['q'] as String? ?? 'No Quote Text',  // Default to a placeholder if missing
      author: json['a'] as String? ?? 'Unknown Author',  // Default to a placeholder if missing
      imageUrl: json['i'] as String?,  // Allow null value if missing
      characterCount: int.tryParse(json['c']?.toString() ?? '0'),  // Default to 0 if missing or invalid
      htmlFormat: json['h'] as String? ?? '',  // Default to empty string if missing
    );
  }

  // Method to convert Quote object to JSON format
  Map<String, dynamic> toJson() {
    return {
      'q': quoteText,
      'a': author,
      'i': imageUrl,  // Nullable field, will be omitted if null
      'c': characterCount,
      'h': htmlFormat,
    };
  }
}
