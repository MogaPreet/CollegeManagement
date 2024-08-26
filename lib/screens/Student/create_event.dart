import 'package:cms/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';

class CreateEventPage extends ConsumerStatefulWidget {
  const CreateEventPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends ConsumerState<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? _selectedDate;
  List<String> _selectedTeamMembers = [];
  String _selectedYear = 'First Year'; // Default selected year

  @override
  Widget build(BuildContext context) {
    final studentsProvider = ref.watch(studentsListProvider(_selectedYear));
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Time (HH:MM AM/PM)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a time';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 8, right: 8),
                title: const Text('Date'),
                subtitle: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now().add(const Duration(days: 1)),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null && pickedDate != _selectedDate) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              DropdownButtonFormField<String>(
                borderRadius: BorderRadius.circular(16),
                value: _selectedYear,
                items: <String>[
                  'First Year',
                  'Second Year',
                  'Third Year',
                  'Fourth Year'
                ].map((String year) {
                  return DropdownMenuItem<String>(
                    value: year,
                    child: Text(year),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedYear = newValue!;
                  });
                },
                decoration: const InputDecoration(
                    labelText: 'Select Year', border: OutlineInputBorder()),
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              const Text('Add Team Members'),
              studentsProvider.when(
                data: (students) {
                  return Wrap(
                    spacing: 8.0,
                    children: students.map((student) {
                      return FilterChip(
                        label: Text(student.firstName ?? ""),
                        selectedColor: Colors.green.withOpacity(.8),
                        selected: _selectedTeamMembers.contains(student.uid),
                        onSelected: (isSelected) {
                          setState(() {
                            if (isSelected) {
                              _selectedTeamMembers.add(student.uid ?? "");
                            } else {
                              _selectedTeamMembers.remove(student.uid ?? "");
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
                loading: () => Shimmer.fromColors(
                    baseColor: Colors.red,
                    highlightColor: Colors.black,
                    child: const SizedBox(
                      height: 20,
                      width: 50,
                    )),
                error: (error, stack) => Text('Error: $error'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: _selectedDate != null
                        ? Colors.green.withOpacity(.8)
                        : Colors.green.withOpacity(.5)),
                child: const Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      Uuid uid = const Uuid();
      var id = uid.v4();
      try {
        await FirebaseFirestore.instance.collection('events').doc(id).set({
          'id': id,
          'title': _titleController.text,
          'description': _descriptionController.text,
          'location': _locationController.text,
          'date': _selectedDate,
          'time': _timeController.text,
          'teamMembers': _selectedTeamMembers,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event: $e')),
        );
      }
    }
  }
}

final studentsListProvider =
    StreamProvider.family<List<StudentModel>, String>((ref, year) {
  return FirebaseFirestore.instance
      .collection('students')
      .where('currentYear', isEqualTo: year)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => StudentModel.fromMap(doc.data()))
        .toList();
  });
});
