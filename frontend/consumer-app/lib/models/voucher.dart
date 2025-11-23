class Voucher {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final List<double> denominations;
  final String merchantName;
  final String? categoryName;
  final double? rating;
  final int? totalReviews;
  final bool isAvailable;
  final DateTime? validUntil;

  Voucher({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.denominations,
    required this.merchantName,
    this.categoryName,
    this.rating,
    this.totalReviews,
    required this.isAvailable,
    this.validUntil,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      denominations: (json['denominations'] as List?)
          ?.map((e) => double.parse(e.toString()))
          .toList() ?? [],
      merchantName: json['merchantName'] ?? 'Unknown Merchant',
      categoryName: json['categoryName'],
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : null,
      totalReviews: json['totalReviews'],
      isAvailable: json['isAvailable'] ?? true,
      validUntil: json['validUntil'] != null ? DateTime.parse(json['validUntil']) : null,
    );
  }
}






































