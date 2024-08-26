import 'package:cms/models/expense.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/Student/events/add_expense.dart';
import 'package:cms/screens/Student/widgets/dashboard_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';

class ExpenseDashboard extends ConsumerWidget {
  final String eventId;
  final StudentModel student;
  final List<String> teamMem;

  const ExpenseDashboard(this.student, this.teamMem,
      {Key? key, required this.eventId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider(eventId));
    final totalExpenses = ref.watch(totalExpensesProvider(eventId));
    final teamMembers = ref.watch(teamMemberProvider(teamMem));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage'),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: teamMembers.when(
                          data: (student) {
                            return ListView.builder(
                                itemCount: student.length,
                                itemBuilder: (context, i) {
                                  return ListTile(
                                    title: Text(student[i].firstName ?? ""),
                                    subtitle:
                                        Text(student[i].currentYear ?? ""),
                                  );
                                });
                          },
                          loading: () => CircularProgressIndicator(),
                          error: (error, stack) => Text('Error: $error'),
                        ),
                      );
                    });
              },
              icon: Icon(Icons.person_2_outlined))
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(
          Icons.add,
        ),
        label: const Text("Add Expense"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AddExpensePage(eventId: eventId, student: student);
              },
            ),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Expenses
            Text(
              'Total Expenses',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              '₹${totalExpenses.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),

            // Expenses Chart
            Expanded(
              flex: 2,
              child: expensesAsync.when(
                data: (e) => ExpenseChart(expenses: e),
                loading: () => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    height: MediaQuery.of(context).size.width * 0.44,
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                error: (error, stack) => Text('Error: $error'),
              ),
            ),

            const SizedBox(height: 20),

            // Filterable List of Expenses
            Expanded(
              flex: 3,
              child: expensesAsync.when(
                data: (expenses) => ExpensesList(expenses: expenses),
                loading: () => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    height: MediaQuery.of(context).size.width * 0.60,
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                error: (error, stack) => Text('Error: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseChart extends StatelessWidget {
  final List<Expense> expenses;

  const ExpenseChart({Key? key, required this.expenses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, double> dailyExpenses = {};
    for (var expense in expenses) {
      final month = '${expense.timestamp.day}/${expense.timestamp.month}';
      dailyExpenses.update(month, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
    }

    // Prepare the data for the chart
    List<BarChartGroupData> barGroups = dailyExpenses.entries.map((entry) {
      int index = dailyExpenses.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.redAccent,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          maxY: (dailyExpenses.values.isNotEmpty)
              ? dailyExpenses.values.reduce((a, b) => a > b ? a : b) + 20
              : 100,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toString(),
                    style: const TextStyle(color: Colors.black, fontSize: 6),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final day = dailyExpenses.keys.toList()[value.toInt()];
                  return Text(
                    day,
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barGroups: barGroups,
        ),
      ),
    );
  }
}

class ExpensesList extends StatelessWidget {
  final List<Expense> expenses;

  const ExpensesList({Key? key, required this.expenses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return ListTile(
          title: Text(expense.description),
          subtitle: Text(
            'Amount: \₹${expense.amount.toStringAsFixed(2)} - By: ${expense.memberName}',
          ),
          trailing: Text(
            expense.timestamp.toLocal().toString().split(' ')[0],
          ),
        );
      },
    );
  }
}

class FilterBar extends ConsumerStatefulWidget {
  const FilterBar({Key? key}) : super(key: key);

  @override
  ConsumerState<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends ConsumerState<FilterBar> {
  String? selectedMemberId;
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Member Filter
        DropdownButton<String>(
          value: selectedMemberId,
          hint: const Text('Filter by Member'),
          items: ['All', ...getUniqueMembers()].map((memberId) {
            return DropdownMenuItem<String>(
              value: memberId,
              child: Text(memberId),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedMemberId = value;
            });
            // Apply the filter with Riverpod state management
          },
        ),

        // Date Filter
        IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );

            if (picked != null) {
              setState(() {
                selectedDate = picked;
              });
              // Apply the filter with Riverpod state management
            }
          },
        ),
      ],
    );
  }

  List<String> getUniqueMembers() {
    // Fetch unique member IDs from the expenses list
    // This is a placeholder method; implement it based on your data source
    return ['Member1', 'Member2'];
  }
}
