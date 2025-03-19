import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/main.dart';
import 'package:cms/models/event.dart';
import 'package:cms/screens/Student/events/add_expense.dart';
import 'package:cms/screens/Student/events/expense_dash.dart';
import 'package:cms/screens/Student/studentHome.dart';
import 'package:cms/screens/Student/widgets/eventCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EventListPage extends ConsumerWidget {
  const EventListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsyncValue = ref.watch(eventsProvider);
    final studentAsyncValue = ref.watch(studentProvider);
    Size size = MediaQuery.of(context).size;
    
    Future<void> refreshEvents() async {
      // Invalidate the providers to trigger a refresh
      ref.invalidate(studentProvider);
      ref.invalidate(eventsProvider);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return RefreshIndicator(
      onRefresh: refreshEvents,
      child: Scaffold(
        body: eventAsyncValue.when(
          data: (events) {
            if (events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 70,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No events available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: refreshEvents,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }
            
            // Sort events by date (most recent first)
            events.sort((a, b) {
              // Handle null dates
              if (a.startDate == null) return 1;
              if (b.startDate == null) return -1;
              
              return b.startDate!.compareTo(a.startDate!);
            });
            
            return ListView.builder(
              itemCount: events.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final theme = ref.watch(themeModeProvider);
                final event = events[index];
                
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    EventCard(event: event),
                    studentAsyncValue.when(
                      data: (student) {
                        if (event.teamMembers.contains(student.uid)) {
                          bool isUpcoming = isEventUpcoming(event);
                          
                          return Padding(
                            padding: EdgeInsets.only(
                              right: size.width * 0.05,
                              top: size.width * 0.02,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isUpcoming)
                                  Chip(
                                    shadowColor: Colors.grey,
                                    color: WidgetStatePropertyAll(
                                        Colors.amber.withOpacity(.2)),
                                    avatar: const Icon(
                                      Icons.upcoming,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      'Upcoming',
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) {
                                        return EventManagementSheet(
                                          student: student,
                                          event: event,
                                          theme: theme,
                                        );
                                      },
                                    );
                                  },
                                  child: Chip(
                                    shadowColor: Colors.grey,
                                    color: WidgetStatePropertyAll(
                                        Colors.white.withOpacity(.6)),
                                    avatar: Icon(
                                      Icons.event_note_outlined,
                                      color: theme == ThemeMode.dark
                                          ? Colors.white
                                          : Colors.green.withOpacity(.9),
                                      size: 18,
                                    ),
                                    label: Text(
                                      'Manage',
                                      style: TextStyle(
                                        color: theme == ThemeMode.dark
                                            ? Colors.white
                                            : Colors.green.withOpacity(.9),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    elevation: 2,
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      loading: () => const SizedBox(),
                      error: (error, stackTrace) => const SizedBox(),
                    )
                  ],
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${error.toString()}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: refreshEvents,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  bool isEventUpcoming(Event event) {
    if (event.startDate == null) return false;
    
    // Event is upcoming if it starts in the future
    return event.startDate!.isAfter(DateTime.now());
  }
}

class EventManagementSheet extends StatelessWidget {
  final dynamic student;
  final Event event;
  final ThemeMode theme;

  const EventManagementSheet({
    Key? key,
    required this.student,
    required this.event,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('MMM dd, yyyy');
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme == ThemeMode.dark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Event Management',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme == ThemeMode.dark ? Colors.white : Colors.black,
            ),
          ),
          const Divider(),
          const SizedBox(height: 10),
          
          // Event details section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme == ThemeMode.dark 
                  ? Colors.grey[800] 
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      event.startDate != null 
                          ? dateFormat.format(event.startDate!) 
                          : "No date specified",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "${event.teamMembers.length} team members",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (event.estimatedBudget != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Budget estimate available",
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context: context,
                icon: Icons.assessment,
                label: 'Budget Dashboard',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExpenseDashboard(
                        student,
                        event.teamMembers,
                        eventId: event.id,
                      ),
                    ),
                  );
                },
              ),
              _buildActionButton(
                context: context,
                icon: Icons.add_card,
                label: 'Add Expense',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddExpensePage(
                        eventId: event.id,
                        student: student,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context: context,
                icon: Icons.description,
                label: 'View Budget Plan',
                onTap: () {
                  Navigator.pop(context);
                  if (event.estimatedBudget != null) {
                    _showBudgetPlan(context, event.estimatedBudget!, event.title);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No budget plan available for this event'),
                      ),
                    );
                  }
                },
              ),
              _buildActionButton(
                context: context,
                icon: Icons.email,
                label: 'Invite Members',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement invite functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invite functionality coming soon!'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: theme == ThemeMode.dark ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: theme == ThemeMode.dark ? Colors.white70 : Colors.black87,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme == ThemeMode.dark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showBudgetPlan(BuildContext context, String budget, String eventTitle) {
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
            color: theme == ThemeMode.dark ? Colors.grey[900] : Colors.white,
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
                  color: theme == ThemeMode.dark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Budget Plan: $eventTitle',
                        style: const TextStyle(
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
                    budget,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: theme == ThemeMode.dark ? Colors.white : Colors.black87,
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
}

final eventsProvider = StreamProvider<List<Event>>((ref) {
  return FirebaseFirestore.instance
      .collection('events')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return Event.fromMap(doc.data());
    }).toList();
  });
});