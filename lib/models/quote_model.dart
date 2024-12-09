class Quote {
  final String quoteText;
  final String author;
  final String? imageUrl;
  final int? characterCount;
  final String htmlFormat;

  Quote({
    required this.quoteText,
    required this.author,
    this.imageUrl,
    required this.characterCount,
    required this.htmlFormat,
  });

  // Factory constructor to create a Quote object from JSON data
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      quoteText: json['q'] as String? ?? 'No Quote Text',
      author: json['a'] as String? ?? 'Unknown Author',
      imageUrl: json['i'] as String?,
      characterCount: int.tryParse(json['c']?.toString() ?? '0'),
      htmlFormat: json['h'] as String? ?? '',
    );
  }

  // Method to convert Quote object to JSON format
  Map<String, dynamic> toJson() {
    return {
      'q': quoteText,
      'a': author,
      'i': imageUrl,
      'c': characterCount,
      'h': htmlFormat,
    };
  }
}
