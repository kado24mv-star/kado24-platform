import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';

class CreateVoucherScreen extends StatefulWidget {
  const CreateVoucherScreen({Key? key}) : super(key: key);

  @override
  State<CreateVoucherScreen> createState() => _CreateVoucherScreenState();
}

class _CreateVoucherScreenState extends State<CreateVoucherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? _selectedImageUrl; // Store the image URL for preview
  int? selectedCategoryId;
  List<double> denominations = [5.0, 10.0, 25.0];
  bool unlimitedStock = false;
  int stockQuantity = 100;
  bool _isLoading = false;

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
                  hintText: 'e.g., Coffee Voucher',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  helperText: 'Enter a clear, descriptive title for your voucher',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Voucher title is required' : null,
              ),

              const SizedBox(height: 16),

              // Description
              const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe what customers can use this voucher for...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  helperText: 'Provide details about the voucher benefits and usage',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedCategoryId,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: 'Select a category',
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
                validator: (value) => value == null ? 'Please select a category' : null,
              ),

              const SizedBox(height: 16),

              // Denominations
              const Text('Available Prices', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (denominations.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'At least one denomination is required',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 4),
              const Text(
                'Select the prices customers can purchase this voucher for',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...denominations.map((amount) {
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('\$${amount.toStringAsFixed(2)}'),
                          if (denominations.length > 1) ...[
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  denominations.remove(amount);
                                });
                              },
                              child: const Icon(Icons.close, size: 16),
                            ),
                          ],
                        ],
                      ),
                      selected: true,
                      onSelected: (selected) {
                        if (!selected && denominations.length > 1) {
                          setState(() {
                            denominations.remove(amount);
                          });
                        }
                      },
                    );
                  }).toList(),
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 18),
                    label: const Text('Add Price'),
                    onPressed: _addDenomination,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Voucher Image (One image per voucher)
              const Text('Voucher Image', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              // Image Preview
              if (_selectedImageUrl != null && _selectedImageUrl!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _selectedImageUrl!.startsWith('data:')
                        ? Image.memory(
                            base64Decode(_selectedImageUrl!.split(',')[1]),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                              );
                            },
                          )
                        : Image.network(
                            _selectedImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedImageUrl!.startsWith('data:') 
                            ? '✓ Image file selected and ready' 
                            : _selectedImageUrl!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _selectedImageUrl!.startsWith('data:') 
                              ? Colors.green[700] 
                              : Colors.grey[600],
                          fontStyle: FontStyle.italic,
                          fontWeight: _selectedImageUrl!.startsWith('data:') 
                              ? FontWeight.w500 
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: Colors.red,
                      onPressed: () {
                        setState(() {
                          _selectedImageUrl = null;
                          _imageUrlController.clear();
                        });
                      },
                      tooltip: 'Remove image',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Image Input
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _imageUrlController,
                      readOnly: _selectedImageUrl != null && _selectedImageUrl!.startsWith('data:'),
                      decoration: InputDecoration(
                        hintText: _selectedImageUrl != null && _selectedImageUrl!.startsWith('data:') 
                            ? 'Image selected ✓' 
                            : 'Select an image or enter URL',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        helperText: _selectedImageUrl != null && _selectedImageUrl!.startsWith('data:')
                            ? 'Image is ready. Click "Change" to select a different image.'
                            : _selectedImageUrl != null
                                ? 'Image URL entered. You can change it by selecting a new one or entering a different URL.'
                                : 'Browse to select an image file or enter image URL',
                        prefixIcon: const Icon(Icons.image),
                        filled: _selectedImageUrl != null,
                        fillColor: _selectedImageUrl != null ? Colors.green[50] : null,
                        suffixIcon: _selectedImageUrl != null && _selectedImageUrl!.startsWith('data:')
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                      ),
                      keyboardType: TextInputType.url,
                      // Hide base64 string from display - show friendly message instead
                      style: TextStyle(
                        color: _selectedImageUrl != null && _selectedImageUrl!.startsWith('data:')
                            ? Colors.green[700]
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value.trim().isEmpty) {
                            _selectedImageUrl = null;
                          } else if (!value.startsWith('data:')) {
                            _selectedImageUrl = value.trim();
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _pickMainImage,
                    icon: const Icon(Icons.folder_open, size: 18),
                    label: Text(_selectedImageUrl != null ? 'Change' : 'Browse'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FACFE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Stock
              SwitchListTile(
                title: const Text('Unlimited Quantity'),
                subtitle: const Text('Allow unlimited purchases of this voucher'),
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
                    labelText: 'Available Quantity',
                    hintText: 'Number of vouchers available for purchase',
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

  Future<void> _pickMainImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        
        // On web, use bytes property; on other platforms, use path
        if (file.bytes != null) {
          // Convert bytes to base64 data URL (works on web and mobile)
          final base64 = base64Encode(file.bytes!);
          final extension = file.extension ?? 'jpg';
          final mimeType = _getMimeType(extension);
          final dataUrl = 'data:$mimeType;base64,$base64';
          
          setState(() {
            _imageUrlController.text = dataUrl; // Store base64 in controller for submission
            _selectedImageUrl = dataUrl; // Store for preview
            // Note: The text field will show the base64, but we make it readOnly
            // and style it to be less prominent. The preview image is the main visual indicator.
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image selected successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Fallback: if bytes is null, try to use name or show error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to read image file. Please try again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  void _addDenomination() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        String? errorText;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Price'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Price (\$)',
                      hintText: 'e.g., 25.00',
                      prefixText: '\$',
                      helperText: 'Enter the price customers can purchase this voucher for',
                      errorText: errorText,
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        errorText = null;
                      });
                    },
                  ),
                  if (denominations.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Current prices: ${denominations.map((d) => '\$${d.toStringAsFixed(2)}').join(', ')}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final amount = double.tryParse(controller.text);
                    if (amount == null || amount <= 0) {
                      setDialogState(() {
                        errorText = 'Please enter a valid price greater than 0';
                      });
                      return;
                    }
                    if (denominations.contains(amount)) {
                      setDialogState(() {
                        errorText = 'This price already exists';
                      });
                      return;
                    }
                    setState(() {
                      denominations.add(amount);
                      denominations.sort(); // Sort prices in ascending order
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _createVoucher() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Additional validation
    if (denominations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one denomination is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Description is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;

      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.getVoucherUrl()}/api/v1/vouchers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'categoryId': selectedCategoryId ?? 1,
          'denominations': denominations,
          'stockQuantity': unlimitedStock ? null : stockQuantity,
          'unlimitedStock': unlimitedStock,
          'termsAndConditions': 'Standard terms apply',
          'imageUrl': _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null,
        }),
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (response.statusCode == 201 || response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Voucher created successfully! Pending admin approval.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to create voucher');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}




