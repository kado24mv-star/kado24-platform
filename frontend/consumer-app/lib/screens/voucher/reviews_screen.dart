import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import 'write_review_screen.dart';

class ReviewsScreen extends StatefulWidget {
  final int voucherId;
  final double rating;
  final int totalReviews;

  const ReviewsScreen({
    Key? key,
    required this.voucherId,
    required this.rating,
    required this.totalReviews,
  }) : super(key: key);

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<dynamic> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);

    try {
      // Try to fetch reviews from voucher service
      final response = await http.get(
        Uri.parse('${ApiConfig.voucherServiceUrl}/api/v1/vouchers/${widget.voucherId}/reviews'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            _reviews = data['data'] is List ? data['data'] : (data['data']['content'] ?? []);
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      // If endpoint doesn't exist, show empty state
    }

    setState(() {
      _reviews = [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Reviews'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Overall Rating
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.grey[100],
              child: Column(
                children: [
                  Text(
                    widget.rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < widget.rating.floor() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Based on ${widget.totalReviews} reviews',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Reviews List
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  )
                : _reviews.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Icon(Icons.rate_review, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text(
                              'No reviews yet',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to review this voucher!',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) {
                          final review = _reviews[index];
                          return _buildReviewCard(review);
                        },
                      ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WriteReviewScreen(voucherId: widget.voucherId),
            ),
          ).then((_) => _loadReviews());
        },
        backgroundColor: const Color(0xFF667EEA),
        label: const Text('Write Review', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.rate_review, color: Colors.white),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final userName = review['userName'] ?? review['user']?['fullName'] ?? 'Anonymous';
    final rating = (review['rating'] is num) ? review['rating'].toDouble() : 5.0;
    final comment = review['comment'] ?? review['review'] ?? '';
    final createdAt = review['createdAt'] ?? review['date'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < rating.floor() ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                comment,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
            if (createdAt != null) ...[
              const SizedBox(height: 8),
              Text(
                _formatDate(createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    try {
      final date = DateTime.parse(dateStr.toString());
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inDays == 0) {
        if (diff.inHours == 0) {
          return '${diff.inMinutes} minutes ago';
        }
        return '${diff.inHours} hours ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}
