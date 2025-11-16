import 'package:flutter/material.dart';

class CreateVoucherScreen extends StatefulWidget {
  const CreateVoucherScreen({Key? key}) : super(key: key);

  @override
  State<CreateVoucherScreen> createState() => _CreateVoucherScreenState();
}

class _CreateVoucherScreenState extends State<CreateVoucherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int? selectedCategoryId;
  List<double> denominations = [5.0, 10.0, 25.0];
  bool unlimitedStock = false;
  int stockQuantity = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Voucher'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text('Voucher Title', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g., \$25 Coffee Voucher',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),

              const SizedBox(height: 16),

              // Description
              const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe your voucher...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              const SizedBox(height: 16),

              // Category
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedCategoryId,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('🍽️ Food & Dining')),
                  DropdownMenuItem(value: 2, child: Text('🎭 Entertainment')),
                  DropdownMenuItem(value: 3, child: Text('💆 Health & Beauty')),
                  DropdownMenuItem(value: 4, child: Text('🛍️ Shopping')),
                  DropdownMenuItem(value: 5, child: Text('✈️ Travel & Hotels')),
                  DropdownMenuItem(value: 6, child: Text('🔧 Services')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCategoryId = value;
                  });
                },
                validator: (value) => value == null ? 'Please select category' : null,
              ),

              const SizedBox(height: 16),

              // Denominations
              const Text('Available Amounts', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: [
                  ...denominations.map((amount) {
                    return Chip(
                      label: Text('\$${amount.toStringAsFixed(2)}'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: denominations.length > 1
                          ? () {
                              setState(() {
                                denominations.remove(amount);
                              });
                            }
                          : null,
                    );
                  }).toList(),
                  InputChip(
                    label: const Text('+ Add Amount'),
                    onPressed: _addDenomination,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Stock
              SwitchListTile(
                title: const Text('Unlimited Stock'),
                value: unlimitedStock,
                onChanged: (value) {
                  setState(() {
                    unlimitedStock = value;
                  });
                },
              ),

              if (!unlimitedStock) ...[
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: stockQuantity.toString(),
                  decoration: InputDecoration(
                    labelText: 'Stock Quantity',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    stockQuantity = int.tryParse(value) ?? 100;
                  },
                ),
              ],

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _createVoucher,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FACFE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Voucher',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addDenomination() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Amount'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (\$)',
              prefixText: '\$',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final amount = double.tryParse(controller.text);
                if (amount != null && amount > 0) {
                  setState(() {
                    denominations.add(amount);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createVoucher() async {
    if (_formKey.currentState!.validate()) {
      // TODO: Call voucher-service API to create voucher
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voucher created successfully! Pending admin approval.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}




