import 'package:cms/main.dart';
import 'package:cms/models/expense.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/Student/events/add_expense.dart';
import 'package:cms/screens/Student/widgets/dashboard_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseDashboard extends ConsumerStatefulWidget {
  final String eventId;
  final StudentModel student;
  final List<String> teamMem;

  const ExpenseDashboard(this.student, this.teamMem,
      {Key? key, required this.eventId})
      : super(key: key);

  @override
  ConsumerState<ExpenseDashboard> createState() => _ExpenseDashboardState();
}

class _ExpenseDashboardState extends ConsumerState<ExpenseDashboard>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String? _eventBudget;
  double _estimatedTotalBudget = 0;
  Map<String, double> _categoryBudgets = {};
  bool _loadingBudget = true;
  Map<String, Color> categoryColors = {
    'Food and Beverages': Colors.orange,
    'Venue': Colors.purple,
    'Equipment': Colors.blue,
    'Decorations': Colors.pink,
    'Marketing': Colors.teal,
    'Transportation': Colors.indigo,
    'Miscellaneous': Colors.brown,
    'Other': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEventBudget();
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
        final budgetText = eventDoc.data()?['estimatedBudget'] as String?;

        setState(() {
          _eventBudget = budgetText;
          if (budgetText != null) {
            _estimatedTotalBudget = _extractEstimatedTotal(budgetText);
            _categoryBudgets = _extractCategoryBudgets(budgetText);
          }
          _loadingBudget = false;
        });
      } else {
        setState(() {
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

  // Extract rough budget total from the budget text
  double _extractEstimatedTotal(String budgetText) {
    if (budgetText.isEmpty) return 0;

    // Look for "Total Estimated Budget: ₹" pattern
    RegExp totalRegex = RegExp(r'Total Estimated Budget:.*?₹(\d+[,\d]*)');
    final match = totalRegex.firstMatch(budgetText);

    if (match != null && match.groupCount >= 1) {
      final totalString = match.group(1)?.replaceAll(',', '');
      return double.tryParse(totalString ?? '') ?? 0;
    }

    return 0;
  }

  // Extract category budgets from the budget text
  Map<String, double> _extractCategoryBudgets(String budgetText) {
    Map<String, double> result = {};

    // Define patterns for different categories
    final patterns = {
      'Food and Beverages': RegExp(r'Food and Beverages:.*?₹(\d+[,\d]*)'),
      'Venue': RegExp(r'Venue:.*?₹(\d+[,\d]*)'),
      'Equipment': RegExp(r'Equipment:.*?₹(\d+[,\d]*)'),
      'Decorations': RegExp(r'Decorations:.*?₹(\d+[,\d]*)'),
      'Marketing': RegExp(r'Marketing Materials:.*?₹(\d+[,\d]*)'),
      'Transportation': RegExp(r'Transportation:.*?₹(\d+[,\d]*)'),
      'Miscellaneous': RegExp(r'Miscellaneous:.*?₹(\d+[,\d]*)')
    };

    // Extract amounts for each category
    patterns.forEach((category, pattern) {
      final match = pattern.firstMatch(budgetText);
      if (match != null && match.groupCount >= 1) {
        final valueString = match.group(1)?.replaceAll(',', '');
        final value = double.tryParse(valueString ?? '') ?? 0;
        if (value > 0) {
          result[category] = value;
        }
      }
    });

    return result;
  }

  Future<void> refreshDashboard() async {
    // Invalidate the providers to trigger a refresh
    ref.invalidate(expensesProvider);
    ref.invalidate(totalExpensesProvider);
    ref.invalidate(teamMemberProvider);
    await _loadEventBudget();

    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider(widget.eventId));
    final totalExpenses = ref.watch(totalExpensesProvider(widget.eventId));
    final teamMembers = ref.watch(teamMemberProvider(widget.teamMem));
    final theme = ref.watch(themeModeProvider);

    // Determine if we're over budget
    bool isOverBudget =
        _estimatedTotalBudget > 0 && totalExpenses > _estimatedTotalBudget;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: '6 Months'),
            Tab(text: '1 Year'),
          ],
          onTap: (_) {
            // Force rebuild when tab changes
            setState(() {});
          },
        ),
        actions: [
          IconButton(
              tooltip: 'Team Members',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.people),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Team Members',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            Container(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.5,
                              ),
                              child: teamMembers.when(
                                data: (student) {
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: student.length,
                                    itemBuilder: (context, i) {
                                      return ListTile(
                                        leading: CircleAvatar(
                                          child: Text(
                                              student[i].firstName?[0] ?? '?'),
                                        ),
                                        title: Text(student[i].firstName ?? ""),
                                        subtitle:
                                            Text(student[i].currentYear ?? ""),
                                      );
                                    },
                                  );
                                },
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (error, stack) => Text('Error: $error'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.people_outline)),
          if (_eventBudget != null)
            IconButton(
              tooltip: 'View Budget Plan',
              onPressed: () => _showBudgetPlan(context),
              icon: const Icon(Icons.attach_money),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Add Expense"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AddExpensePage(
                    eventId: widget.eventId, student: widget.student);
              },
            ),
          ).then((_) => refreshDashboard());
        },
      ),
      body: RefreshIndicator(
        onRefresh: refreshDashboard,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Budget status card
              if (_estimatedTotalBudget > 0) ...[
                _buildBudgetStatusCard(totalExpenses, theme),
                const SizedBox(height: 20),
              ],

              // Expense stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Total Expenses',
                      '₹${totalExpenses.toStringAsFixed(2)}',
                      isOverBudget ? Colors.red : Colors.green,
                      theme,
                    ),
                  ),
                  const SizedBox(width: 16),
                  expensesAsync.maybeWhen(
                    data: (expenses) {
                      final count = expenses.length;
                      return Expanded(
                        child: _buildStatCard(
                          context,
                          'Expenses Count',
                          count.toString(),
                          Colors.blue,
                          theme,
                        ),
                      );
                    },
                    orElse: () => const Expanded(child: SizedBox()),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Charts section
              Expanded(
                child: expensesAsync.when(
                  data: (expenses) {
                    if (expenses.isEmpty) {
                      return const Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bar_chart,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No expenses recorded yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: constraints.maxHeight,
                              ),
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  // Daily Chart
                                  SingleChildScrollView(
                                    child: ExpenseChart(
                                      expenses: expenses,
                                      periodType: PeriodType.daily,
                                      theme: theme,
                                    ),
                                  ),

                                  // 6 Month Chart
                                  SingleChildScrollView(
                                    child: ExpenseChart(
                                      expenses: expenses,
                                      periodType: PeriodType.sixMonths,
                                      theme: theme,
                                    ),
                                  ),

                                  // 1 Year Chart
                                  SingleChildScrollView(
                                    child: ExpenseChart(
                                      expenses: expenses,
                                      periodType: PeriodType.yearly,
                                      theme: theme,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Error loading chart: $error'),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Category distribution
              expensesAsync.maybeWhen(
                data: (expenses) {
                  if (expenses.isEmpty) return const SizedBox();

                  // Group expenses by category
                  Map<String, double> categoryTotals = {};
                  for (var expense in expenses) {
                    final category = expense.category ?? 'Other';
                    categoryTotals[category] =
                        (categoryTotals[category] ?? 0) + expense.amount;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spending by Category',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: categoryTotals.entries.map((entry) {
                            final category = entry.key;
                            final amount = entry.value;
                            final categoryBudget =
                                _categoryBudgets[category] ?? 0;
                            final isOverCategoryBudget =
                                categoryBudget > 0 && amount > categoryBudget;

                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: (categoryColors[category] ?? Colors.grey)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: isOverCategoryBudget
                                    ? Border.all(color: Colors.red, width: 1)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  if (isOverCategoryBudget)
                                    const Icon(
                                      Icons.warning_amber_outlined,
                                      size: 14,
                                      color: Colors.red,
                                    ),
                                  Text(
                                    '$category: ₹${amount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: categoryColors[category] ??
                                          Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
                orElse: () => const SizedBox(),
              ),

              const SizedBox(height: 16),

              // Expenses list header
              Row(
                children: [
                  Text(
                    'Recent Expenses',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  // Filter dropdown could go here
                ],
              ),

              const SizedBox(height: 8),

              // Expenses list
              Expanded(
                child: expensesAsync.when(
                  data: (expenses) {
                    if (expenses.isEmpty) {
                      return const Center(
                        child: Text(
                          'No expenses recorded yet',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }
                    return ExpensesList(
                      expenses: expenses,
                      categoryColors: categoryColors,
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Error: $error'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetStatusCard(double totalExpenses, ThemeMode theme) {
    final remaining = _estimatedTotalBudget - totalExpenses;
    final percentSpent = totalExpenses / _estimatedTotalBudget;
    final isOverBudget = remaining < 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isOverBudget
          ? Colors.red.shade50
          : (percentSpent > 0.8 ? Colors.amber.shade50 : Colors.green.shade50),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOverBudget
                      ? Icons.warning_amber_rounded
                      : (percentSpent > 0.8
                          ? Icons.info_outline
                          : Icons.check_circle_outline),
                  color: isOverBudget
                      ? Colors.red
                      : (percentSpent > 0.8
                          ? Colors.amber.shade800
                          : Colors.green),
                ),
                const SizedBox(width: 8),
                Text(
                  isOverBudget
                      ? 'Budget Exceeded!'
                      : (percentSpent > 0.8 ? 'Budget Alert' : 'Budget Status'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isOverBudget
                        ? Colors.red
                        : (percentSpent > 0.8
                            ? Colors.amber.shade800
                            : Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Budget',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '₹${_estimatedTotalBudget.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isOverBudget ? 'Over Budget' : 'Remaining',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverBudget ? Colors.red : Colors.grey,
                      ),
                    ),
                    Text(
                      '₹${remaining.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isOverBudget ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentSpent.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: isOverBudget
                  ? Colors.red
                  : (percentSpent > 0.8 ? Colors.amber : Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              '${(percentSpent * 100).toStringAsFixed(1)}% of budget used',
              style: TextStyle(
                fontSize: 12,
                color: isOverBudget
                    ? Colors.red
                    : (percentSpent > 0.8
                        ? Colors.amber.shade800
                        : Colors.green),
              ),
            ),
            if (isOverBudget)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'You are ₹${remaining.abs().toStringAsFixed(2)} over budget!',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    ThemeMode theme,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color:
                    theme == ThemeMode.dark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
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

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}

enum PeriodType { daily, sixMonths, yearly }

class ExpenseChart extends StatelessWidget {
  final List<Expense> expenses;
  final PeriodType periodType;
  final ThemeMode theme;

  const ExpenseChart({
    Key? key,
    required this.expenses,
    required this.periodType,
    required this.theme,
  }) : super(key: key);

  String _getChartTitle() {
    switch (periodType) {
      case PeriodType.daily:
        return 'Daily Expenses (Last 30 Days)';
      case PeriodType.sixMonths:
        return 'Monthly Expenses (Last 6 Months)';
      case PeriodType.yearly:
        return 'Quarterly Expenses (Last Year)';
      default:
        return 'Expenses Overview';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Process data for chart
    Map<String, double> periodExpenses = {};
    final now = DateTime.now();

    switch (periodType) {
      case PeriodType.daily:
        // Group by day for the past 30 days
        for (var expense in expenses) {
          final expenseDate = expense.timestamp;
          if (now.difference(expenseDate).inDays <= 30) {
            final day = DateFormat('d/M').format(expenseDate);
            periodExpenses.update(day, (value) => value + expense.amount,
                ifAbsent: () => expense.amount);
          }
        }
        break;

      case PeriodType.sixMonths:
        // Group by month for the past 6 months
        for (var expense in expenses) {
          final expenseDate = expense.timestamp;
          if (now.difference(expenseDate).inDays <= 180) {
            final month = DateFormat('MMM').format(expenseDate);
            periodExpenses.update(month, (value) => value + expense.amount,
                ifAbsent: () => expense.amount);
          }
        }
        break;

      case PeriodType.yearly:
        // Group by quarter for the past year
        for (var expense in expenses) {
          final expenseDate = expense.timestamp;
          if (now.difference(expenseDate).inDays <= 365) {
            final quarter = 'Q${((expenseDate.month - 1) / 3).floor() + 1}';
            periodExpenses.update(quarter, (value) => value + expense.amount,
                ifAbsent: () => expense.amount);
          }
        }
        break;
    }

    // Sort the data chronologically
    final sortedEntries = periodExpenses.entries.toList();

    if (periodType == PeriodType.daily || periodType == PeriodType.sixMonths) {
      // Sort logic for daily and monthly views
      sortedEntries.sort((a, b) {
        if (periodType == PeriodType.daily) {
          // Parse day/month format
          final partsA = a.key.split('/').map(int.parse).toList();
          final partsB = b.key.split('/').map(int.parse).toList();
          final dateA = DateTime(now.year, partsA[1], partsA[0]);
          final dateB = DateTime(now.year, partsB[1], partsB[0]);
          return dateA.compareTo(dateB);
        } else {
          // Parse month names
          final months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
          ];
          return months.indexOf(a.key) - months.indexOf(b.key);
        }
      });
    } else {
      // Sort for quarterly view
      sortedEntries.sort((a, b) {
        final quarterA = int.parse(a.key.substring(1));
        final quarterB = int.parse(b.key.substring(1));
        return quarterA - quarterB;
      });
    }

    // Prepare bar chart data
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: entry.value,
              color:
                  theme == ThemeMode.dark ? Colors.blueAccent : Colors.orange,
              width: 12, // Slimmer bars
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      );
    }

    if (barGroups.isEmpty) {
      return const Center(
        child: Text('No data available for the selected period'),
      );
    }

    // Calculate warning text if needed
    String? warningText;
    double totalForPeriod = 0;

    // Filter expenses for the current period for warning
    for (var expense in expenses) {
      if (periodType == PeriodType.daily) {
        if (now.difference(expense.timestamp).inDays <= 7) {
          totalForPeriod += expense.amount;
        }
      } else if (periodType == PeriodType.sixMonths) {
        if (now.difference(expense.timestamp).inDays <= 30) {
          totalForPeriod += expense.amount;
        }
      } else {
        if (now.difference(expense.timestamp).inDays <= 90) {
          totalForPeriod += expense.amount;
        }
      }
    }

    // Set warning threshold and text
    double threshold = 0;
    String periodLabel = "";

    if (periodType == PeriodType.daily) {
      threshold = 1000;
      periodLabel = "week";
    } else if (periodType == PeriodType.sixMonths) {
      threshold = 5000;
      periodLabel = "month";
    } else {
      threshold = 15000;
      periodLabel = "quarter";
    }

    if (totalForPeriod > threshold) {
      warningText =
          'High spending: ₹${totalForPeriod.toStringAsFixed(0)} ($periodLabel)';
    }

    // Build the widget with a simplified layout
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with warning if needed
          Row(
            children: [
              Expanded(
                child: Text(
                  _getChartTitle(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        theme == ThemeMode.dark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              // Show warning indicator if needed
              if (warningText != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border:
                        Border.all(color: Colors.amber.shade700, width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: Colors.amber.shade700,
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'High',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Chart - using Container with fixed height instead of Expanded/Flexible
          SizedBox(
            height: 140, // Fixed height for the chart
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: periodExpenses.values.isNotEmpty
                    ? periodExpenses.values.reduce((a, b) => a > b ? a : b) *
                        1.2
                    : 100,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: periodExpenses.values.isNotEmpty
                      ? periodExpenses.values.reduce((a, b) => a > b ? a : b) /
                          4
                      : 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 0.5, // Thinner lines
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24, // Reduced size further
                      getTitlesWidget: (value, meta) {
                        // Skip some labels if too many
                        if (value % 2 != 0 &&
                            value !=
                                periodExpenses.values
                                    .reduce((a, b) => a > b ? a : b)) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            value > 999
                                ? '${(value / 1000).toStringAsFixed(1)}k'
                                : value.toInt().toString(),
                            style: TextStyle(
                              color: theme == ThemeMode.dark
                                  ? Colors.white60
                                  : Colors.grey.shade600,
                              fontSize: 8, // Even smaller font
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value >= 0 && value < sortedEntries.length) {
                          // Skip some labels if too many entries
                          if (sortedEntries.length > 6 &&
                              value % 2 != 0 &&
                              value != sortedEntries.length - 1) {
                            return const SizedBox();
                          }

                          final label = sortedEntries[value.toInt()].key;
                          return Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: theme == ThemeMode.dark
                                    ? Colors.white60
                                    : Colors.grey.shade700,
                                fontSize: 8, // Even smaller font
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
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
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: const EdgeInsets.all(6),
                    tooltipMargin: 4,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final entry = sortedEntries[group.x.toInt()];
                      return BarTooltipItem(
                        '₹${entry.value.toStringAsFixed(0)}',
                        TextStyle(
                          color: theme == ThemeMode.dark
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                        children: [
                          TextSpan(
                            text: '\n${entry.key}',
                            style: TextStyle(
                              color: theme == ThemeMode.dark
                                  ? Colors.grey[300]
                                  : Colors.grey[600],
                              fontSize: 9,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),

          // Warning text row - only if needed and there's a warning
          if (warningText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                warningText,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.amber.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ExpensesList extends StatelessWidget {
  final List<Expense> expenses;
  final Map<String, Color> categoryColors;

  const ExpensesList({
    Key? key,
    required this.expenses,
    required this.categoryColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sort expenses by date (newest first)
    final sortedExpenses = List<Expense>.from(expenses);
    sortedExpenses.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Expanded(
      child: ListView.builder(
        itemCount: sortedExpenses.length,
        itemBuilder: (context, index) {
          final expense = sortedExpenses[index];
          final category = expense.category ?? 'Other';
          final categoryColor = categoryColors[category] ?? Colors.grey;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: categoryColor.withOpacity(0.2),
                child: Icon(
                  _getCategoryIcon(category),
                  color: categoryColor,
                  size: 20,
                ),
              ),
              title: Text(
                expense.description,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                '${DateFormat('MMM d, yyyy').format(expense.timestamp)} • ${expense.memberName ?? ""}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${expense.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: expense.amount > 1000
                          ? Colors.red.shade700
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 10,
                        color: categoryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                if (expense.billImageUrl != null) {
                  _showBillImage(context, expense);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No receipt image available')),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food and Beverages':
        return Icons.restaurant;
      case 'Venue':
        return Icons.location_city;
      case 'Equipment':
        return Icons.devices;
      case 'Decorations':
        return Icons.cake;
      case 'Marketing':
        return Icons.campaign;
      case 'Transportation':
        return Icons.directions_car;
      case 'Miscellaneous':
        return Icons.all_inbox;
      case 'Other':
      default:
        return Icons.category;
    }
  }

  void _showBillImage(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Receipt: ${expense.description}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Image.network(
                expense.billImageUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 40, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Failed to load image'),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM d, yyyy').format(expense.timestamp),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  Text(
                    '₹${expense.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Providers for expense data
final expensesProvider =
    StreamProvider.family<List<Expense>, String>((ref, eventId) {
  return FirebaseFirestore.instance
      .collection('events')
      .doc(eventId)
      .collection('expenses')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Expense(
        id: doc.id,
        description: data['description'] ?? '',
        amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
        memberId: data['memberId'] ?? '',
        memberName: data['memberName'] ?? '',
        timestamp: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        billImageUrl: data['billImageUrl'],
        category: data['category'] ?? 'Other',
      );
    }).toList();
  });
});

final totalExpensesProvider = Provider.family<double, String>((ref, eventId) {
  final expensesAsyncValue = ref.watch(expensesProvider(eventId));
  return expensesAsyncValue.maybeWhen(
    data: (expenses) {
      if (expenses.isEmpty) return 0;
      return expenses.fold(0, (total, expense) => total + expense.amount);
    },
    orElse: () => 0,
  );
});

final teamMemberProvider =
    Provider.family<AsyncValue<List<StudentModel>>, List<String>>(
        (ref, teamMem) {
  return ref.watch(teamsProvider(teamMem));
});

// Provider to fetch team members
final teamsProvider =
    StreamProvider.family<List<StudentModel>, List<String>>((ref, teamMem) {
  if (teamMem.isEmpty) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .where('uid', whereIn: teamMem)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      // Add the document ID as a field
      data['id'] = doc.id;
      return StudentModel.fromMap(data);
    }).toList();
  });
});
