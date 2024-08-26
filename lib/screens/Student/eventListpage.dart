import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/event.dart';
import 'package:cms/screens/Student/events/add_expense.dart';
import 'package:cms/screens/Student/events/expense_dash.dart';
import 'package:cms/screens/Student/studentHome.dart';
import 'package:cms/screens/Student/widgets/eventCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventListPage extends ConsumerWidget {
  const EventListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsyncValue = ref.watch(eventsProvider);
    final studentAsyncValue = ref.watch(studentProvider);
    Size size = MediaQuery.of(context).size;
    return eventAsyncValue.when(
      data: (events) {
        if (events.isEmpty) {
          return const Center(
            child: Text('No events available'),
          );
        }
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            return Stack(
              alignment: Alignment.topRight,
              children: [
                EventCard(event: events[index]),
                studentAsyncValue.when(
                  data: (student) {
                    if (events[index].teamMembers.contains(student.uid)) {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: size.width * 0.05,
                          top: size.width * 0.02,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ExpenseDashboard(
                                student,
                                events[index].teamMembers,
                                eventId: events[index].id,
                              );
                            }));
                          },
                          child: Chip(
                            shadowColor: Colors.grey,
                            color: WidgetStatePropertyAll(
                                Colors.white.withOpacity(.6)),
                            avatar: Icon(
                              Icons.event_note_outlined,
                              color: Colors.green.withOpacity(.6),
                            ),
                            label: Text(
                              'Manage',
                              style: TextStyle(
                                color: Colors.green.withOpacity(.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            elevation: 2,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) =>
                      Center(child: Text('Error: $error')),
                )
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
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
