import 'dart:io';
import 'package:cms/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

class AddExpensePage extends ConsumerStatefulWidget {
  final String eventId;
  final StudentModel student;

  const AddExpensePage({Key? key, required this.eventId, required this.student})
      : super(key: key);

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  File? _billImage;
  bool _isLoading = false;
  
  // Budget information
  String? _eventBudget;
  bool _loadingBudget = true;
  String _selectedCategory = 'Other';
  final List<String> _expenseCategories = [
    'Food and Beverages',
    'Venue',
    'Equipment',
    'Decorations',
    'Marketing',
    'Transportation',
    'Miscellaneous',
    'Other',
  ];
  
  // Budget overview stats
  double _totalBudgetSpent = 0;
  double _remainingBudget = 0;
  Map<String, double> _categorySpending = {};
  
  @override
  void initState() {
    super.initState();
    _loadEventBudget();
    _loadExpenseStats();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _loadEventBudget() async {
    setState(() {
      _loadingBudget = true;
    });
    
    try {
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();
      
      if (eventDoc.exists) {
        setState(() {
          _eventBudget = eventDoc.data()?['estimatedBudget'];
          _loadingBudget = false;
        });
      }
    } catch (e) {
      print('Error loading budget: $e');
      setState(() {
        _loadingBudget = false;
      });
    }
  }
  
  Future<void> _loadExpenseStats() async {
    try {
      final expenses = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('expenses')
          .get();
      
      double total = 0;
      Map<String, double> categoryTotals = {};
      
      for (var expense in expenses.docs) {
        final amount = expense.data()['amount'] as double? ?? 0;
        final category = expense.data()['category'] as String? ?? 'Other';
        
        total += amount;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      }
      
      setState(() {
        _totalBudgetSpent = total;
        _categorySpending = categoryTotals;
        
        // Estimated remaining budget (if we have a number from the budget)
        if (_totalBudgetSpent > 0) {
          _remainingBudget = _extractEstimatedTotal(_eventBudget) - _totalBudgetSpent;
        }
      });
    } catch (e) {
      print('Error loading expense stats: $e');
    }
  }
  
  // Extract rough budget total from the budget text
  double _extractEstimatedTotal(String? budgetText) {
    if (budgetText == null || budgetText.isEmpty) return 0;
    
    // Look for "Total Estimated Budget: ₹" pattern
    RegExp totalRegex = RegExp(r'Total Estimated Budget:.*?₹(\d+[,\d]*)');
    final match = totalRegex.firstMatch(budgetText);
    
    if (match != null && match.groupCount >= 1) {
      final totalString = match.group(1)?.replaceAll(',', '');
      return double.tryParse(totalString ?? '') ?? 0;
    }
    
    return 0;
  }

  Future<void> _pickImageAndExtractText() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final inputImage = GoogleVisionImage.fromFile(File(pickedFile.path));
        final textRecognizer = GoogleVision.instance.textRecognizer();
        final visionText = await textRecognizer.processImage(inputImage);
  
        // Extracted text
        String extractedText = visionText.text ?? "";
        
        // Try to extract amount from text (look for currency patterns)
        RegExp amountRegex = RegExp(r'(Rs\.?|₹|INR)\s*(\d+[,\d]*\.?\d*)');
        final amountMatch = amountRegex.firstMatch(extractedText);
        
        if (amountMatch != null && amountMatch.groupCount >= 2) {
          String amountText = amountMatch.group(2)?.replaceAll(',', '') ?? '';
          _amountController.text = amountText;
        } else {
          // Fallback: try to find any number that looks like a total
          RegExp fallbackRegex = RegExp(r'total:?\s*(?:Rs\.?|₹|INR)?\s*(\d+[,\d]*\.?\d*)', caseSensitive: false);
          final fallbackMatch = fallbackRegex.firstMatch(extractedText);
          
          if (fallbackMatch != null && fallbackMatch.groupCount >= 1) {
            String amountText = fallbackMatch.group(1)?.replaceAll(',', '') ?? '';
            _amountController.text = amountText;
          }
        }
        
        // Try to extract a description or merchant name
        List<String> lines = extractedText.split('\n');
        for (String line in lines) {
          if (line.length > 5 && !line.contains('Rs') && !line.contains('₹')) {
            _descriptionController.text = line.trim();
            break;
          }
        }
  
        textRecognizer.close();
        setState(() {
          _billImage = File(pickedFile.path);
          _isLoading = false;
        });
      } catch (e) {
        print('Error processing image: $e');
        setState(() {
          _billImage = File(pickedFile.path);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.photo_library),
              tooltip: 'Scan receipt',
              onPressed: _pickImageAndExtractText,
            ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Column(
            children: [
              // Budget summary card
              if (_eventBudget != null) _buildBudgetSummary(),
              
              // Form for adding expense
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Category dropdown
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Expense Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          prefixIcon: Icon(Icons.category),
                        ),
                        value: _selectedCategory,
                        items: _expenseCategories.map((category) => 
                          DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          )
                        ).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Expense Description',
                          hintText: 'What was this expense for?',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Amount field
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount (₹)',
                          hintText: 'Enter amount in rupees',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          prefixIcon: Icon(Icons.currency_rupee),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Date field
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.date_range),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Bill upload button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.receipt_long),
                        label: Text(_billImage == null 
                          ? 'Upload Receipt Image' 
                          : 'Change Receipt Image'
                        ),
                        onPressed: _pickImageAndExtractText,
                      ),
                      
                      // Bill image preview
                      if (_billImage != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.file(
                                _billImage!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _billImage = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 30),
                      
                      // Submit button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.save),
                          label: const Text(
                            'SAVE EXPENSE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _submitForm,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
  
  // Build budget summary card
  Widget _buildBudgetSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Budget Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          Row(
            children: [
              _buildBudgetItem(
                'Total Spent', 
                '₹${_totalBudgetSpent.toStringAsFixed(2)}',
                Colors.orange
              ),
              if (_remainingBudget > 0) ...[
                const SizedBox(width: 16),
                _buildBudgetItem(
                  'Remaining', 
                  '₹${_remainingBudget.toStringAsFixed(2)}',
                  Colors.green
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          if (_categorySpending.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Category Spending',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categorySpending.entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(entry.key).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${entry.key}: ₹${entry.value.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: _getCategoryColor(entry.key),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              _showBudgetPlan(context);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.visibility,
                  size: 16,
                  color: Colors.blue,
                ),
                SizedBox(width: 4),
                Text(
                  'View full budget plan',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Individual budget stat item
  Widget _buildBudgetItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show the full budget plan
  void _showBudgetPlan(BuildContext context) {
    if (_eventBudget == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Event Budget Plan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _eventBudget!,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Get color for category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food and Beverages':
        return Colors.orange.shade700;
      case 'Venue':
        return Colors.purple.shade700;
      case 'Equipment':
        return Colors.blue.shade700;
      case 'Decorations':
        return Colors.pink.shade700;
      case 'Marketing':
        return Colors.teal.shade700;
      case 'Transportation':
        return Colors.indigo.shade700;
      case 'Miscellaneous':
        return Colors.brown.shade700;
      case 'Other':
      default:
        return Colors.grey.shade700;
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        if (widget.student.uid == null) {
          throw Exception('User not logged in');
        }

        String? billImageUrl;
        if (_billImage != null) {
          final fileName = '${widget.student.uid}_${DateTime.now().millisecondsSinceEpoch}_${path.basename(_billImage!.path)}';
          final storageRef =
              FirebaseStorage.instance.ref().child('bill_images/$fileName');
          final uploadTask = await storageRef.putFile(_billImage!);
          billImageUrl = await uploadTask.ref.getDownloadURL();
        }

        final expenseData = {
          'description': _descriptionController.text,
          'amount': double.parse(_amountController.text),
          'memberId': widget.student.uid,
          'memberName': widget.student.firstName ?? 'Unknown',
          'billImageUrl': billImageUrl,
          'category': _selectedCategory,
          'date': DateFormat('yyyy-MM-dd').parse(_dateController.text),
          'timestamp': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .collection('expenses')
            .add(expenseData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add expense: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}