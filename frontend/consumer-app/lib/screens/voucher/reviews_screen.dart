import 'package:flutter/material.dart';

class ReviewsScreen extends StatelessWidget {
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
                    rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating.floor() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Based on $totalReviews reviews',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Reviews List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: 5, // TODO: Load actual reviews
              itemBuilder: (context, index) {
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
                            const Text(
                              'User Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < 4 ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Great service! The voucher was easy to use and the staff was friendly.',
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '2 days ago',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to write review
        },
        backgroundColor: const Color(0xFF667EEA),
        label: const Text('Write Review', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.rate_review, color: Colors.white),
      ),
    );
  }
}















