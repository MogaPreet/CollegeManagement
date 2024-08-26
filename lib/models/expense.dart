import 'package:cms/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Model for Expense
class Expense {
  final String description;
  final double amount;
  final String memberId;
  final String memberName;
  final DateTime timestamp;

  Expense({
    required this.description,
    required this.amount,
    required this.memberId,
    required this.memberName,
    required this.timestamp,
  });

  factory Expense.fromMap(Map<String, dynamic> data) {
    return Expense(
      description: data['description'] ?? '',
      amount: data['amount']?.toDouble() ?? 0.0,
      memberId: data['memberId'] ?? '',
      memberName: data['memberName'] ?? 'Unknown',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

// Providers
final expensesProvider =
    StreamProvider.autoDispose.family<List<Expense>, String>((ref, eventId) {
  return FirebaseFirestore.instance
      .collection('events')
      .doc(eventId)
      .collection('expenses')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Expense.fromMap(doc.data())).toList();
  });
});
final teamMemberProvider = StreamProvider.autoDispose
    .family<List<StudentModel>, List<String>>((ref, temMembers) {
  return FirebaseFirestore.instance
      .collection('students')
      .where('uid', whereIn: temMembers)
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
