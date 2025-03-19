import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Expense Categories
enum ExpenseCategory {
  foodAndBeverages,
  venue,
  equipment,
  decorations,
  marketing,
  transportation,
  miscellaneous,
  other
}

// Model for Expense
class Expense {
  final String id;
  final String description;
  final double amount;
  final String memberId;
  final String memberName;
  final DateTime timestamp;
  final String? billImageUrl;
  final String? category;
  final String? notes;
  final bool isApproved;
  final String? approvedBy;
  final DateTime? approvalDate;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.memberId,
    required this.memberName,
    required this.timestamp,
    this.billImageUrl,
    this.category = 'Other',
    this.notes,
    this.isApproved = false,
    this.approvedBy,
    this.approvalDate,
  });

  factory Expense.fromMap(Map<String, dynamic> data, {String? id}) {
    return Expense(
      id: id ?? data['id'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      memberId: data['memberId'] ?? '',
      memberName: data['memberName'] ?? 'Unknown',
      timestamp: data['timestamp'] is Timestamp
          ? (data['timestamp'] as Timestamp).toDate()
          : data['date'] is Timestamp
              ? (data['date'] as Timestamp).toDate()
              : DateTime.now(),
      billImageUrl: data['billImageUrl'],
      category: data['category'] ?? 'Other',
      notes: data['notes'],
      isApproved: data['isApproved'] ?? false,
      approvedBy: data['approvedBy'],
      approvalDate: data['approvalDate'] is Timestamp
          ? (data['approvalDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'memberId': memberId,
      'memberName': memberName,
      'timestamp': Timestamp.fromDate(timestamp),
      'date': Timestamp.fromDate(timestamp), // For backward compatibility
      'billImageUrl': billImageUrl,
      'category': category,
      'notes': notes,
      'isApproved': isApproved,
      'approvedBy': approvedBy,
      'approvalDate': approvalDate != null ? Timestamp.fromDate(approvalDate!) : null,
    };
  }

  // Create a copy of this expense with some fields replaced
  Expense copyWith({
    String? id,
    String? description,
    double? amount,
    String? memberId,
    String? memberName,
    DateTime? timestamp,
    String? billImageUrl,
    String? category,
    String? notes,
    bool? isApproved,
    String? approvedBy,
    DateTime? approvalDate,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      timestamp: timestamp ?? this.timestamp,
      billImageUrl: billImageUrl ?? this.billImageUrl,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      isApproved: isApproved ?? this.isApproved,
      approvedBy: approvedBy ?? this.approvedBy,
      approvalDate: approvalDate ?? this.approvalDate,
    );
  }

  // Get color based on category
  Color getCategoryColor() {
    switch (category?.toLowerCase()) {
      case 'food and beverages':
        return Colors.orange.shade700;
      case 'venue':
        return Colors.purple.shade700;
      case 'equipment':
        return Colors.blue.shade700;
      case 'decorations':
        return Colors.pink.shade700;
      case 'marketing':
        return Colors.teal.shade700;
      case 'transportation':
        return Colors.indigo.shade700;
      case 'miscellaneous':
        return Colors.brown.shade700;
      case 'other':
      default:
        return Colors.grey.shade700;
    }
  }

  // Get icon based on category
  IconData getCategoryIcon() {
    switch (category?.toLowerCase()) {
      case 'food and beverages':
        return Icons.restaurant;
      case 'venue':
        return Icons.location_city;
      case 'equipment':
        return Icons.devices;
      case 'decorations':
        return Icons.cake;
      case 'marketing':
        return Icons.campaign;
      case 'transportation':
        return Icons.directions_car;
      case 'miscellaneous':
        return Icons.all_inbox;
      case 'other':
      default:
        return Icons.category;
    }
  }
  
  // Helper to format amount as currency string
  String get formattedAmount => '₹${amount.toStringAsFixed(2)}';
  
  // Helper to check if expense is high-value
  bool get isHighValue => amount > 1000;
  
  // Helper to check if expense has receipt
  bool get hasReceipt => billImageUrl != null && billImageUrl!.isNotEmpty;
  
  // Helper to get formatted date
  String get formattedDate => '${timestamp.day}/${timestamp.month}/${timestamp.year}';
}

// Providers
final expensesProvider =
    StreamProvider.autoDispose.family<List<Expense>, String>((ref, eventId) {
  return FirebaseFirestore.instance
      .collection('events')
      .doc(eventId)
      .collection('expenses')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => Expense.fromMap(doc.data(), id: doc.id))
        .toList();
  });
});

// Provider for expenses by period
final expensesByPeriodProvider = Provider.family<List<Expense>, ExpensePeriodParams>(
  (ref, params) {
    final allExpenses = ref.watch(expensesProvider(params.eventId)).value ?? [];
    final now = DateTime.now();
    
    switch (params.periodType) {
      case PeriodType.daily:
        // Last 30 days
        return allExpenses.where(
          (expense) => now.difference(expense.timestamp).inDays <= 30
        ).toList();
      
      case PeriodType.sixMonths:
        // Last 6 months
        return allExpenses.where(
          (expense) => now.difference(expense.timestamp).inDays <= 180
        ).toList();
      
      case PeriodType.yearly:
        // Last year
        return allExpenses.where(
          (expense) => now.difference(expense.timestamp).inDays <= 365
        ).toList();
        
      default:
        return allExpenses;
    }
  }
);

// Provider for expenses by category
final expensesByCategoryProvider = Provider.family<Map<String, double>, String>(
  (ref, eventId) {
    final expenses = ref.watch(expensesProvider(eventId)).value ?? [];
    
    // Group by category
    Map<String, double> result = {};
    
    for (final expense in expenses) {
      final category = expense.category ?? 'Other';
      result.update(
        category, 
        (value) => value + expense.amount, 
        ifAbsent: () => expense.amount
      );
    }
    
    return result;
  }
);

final teamMemberProvider = StreamProvider.autoDispose
    .family<List<StudentModel>, List<String>>((ref, teamMembers) {
  if (teamMembers.isEmpty) {
    return Stream.value([]);
  }
  
  return FirebaseFirestore.instance
      .collection('users')
      .where('uid', whereIn: teamMembers)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => StudentModel.fromMap(doc.data()))
        .toList();
  });
});

// Provider for total expenses
final totalExpensesProvider =
    Provider.autoDispose.family<double, String>((ref, eventId) {
  final expensesAsyncValue = ref.watch(expensesProvider(eventId));

  final expenses = expensesAsyncValue.maybeWhen(
    data: (data) => data,
    orElse: () => [],
  );

  // Calculate the total expenses
  return expenses.fold(0.0, (total, expense) => total + expense.amount);
});

// Provider for expenses by member
final expensesByMemberProvider = Provider.family<Map<String, double>, String>(
  (ref, eventId) {
    final expenses = ref.watch(expensesProvider(eventId)).value ?? [];
    
    // Group by member
    Map<String, double> result = {};
    
    for (final expense in expenses) {
      result.update(
        expense.memberName, 
        (value) => value + expense.amount, 
        ifAbsent: () => expense.amount
      );
    }
    
    return result;
  }
);

// Define period types for charts
enum PeriodType {
  daily,
  sixMonths,
  yearly,
}

// Parameters class for expense period provider
class ExpensePeriodParams {
  final String eventId;
  final PeriodType periodType;
  
  ExpensePeriodParams(this.eventId, this.periodType);
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is ExpensePeriodParams &&
    runtimeType == other.runtimeType &&
    eventId == other.eventId &&
    periodType == other.periodType;

  @override
  int get hashCode => eventId.hashCode ^ periodType.hashCode;
}