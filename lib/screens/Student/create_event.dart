import 'package:cms/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';
import 'package:cms/services/gemini_budget_service.dart';

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
  final TextEditingController _attendeesController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  
  final GeminiBudgetService _budgetService = GeminiBudgetService();
  
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  List<String> _selectedTeamMembers = [];
  String _selectedYear = 'First Year'; // Default selected year
  String _locationType = 'In-College'; // Default location type
  bool isLoading = false;
  String? _estimatedBudget;
  bool _showBudgetEstimate = false;
  bool _budgetConfirmed = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize fee to 0 for in-college events
    if (_locationType == 'In-College') {
      _feeController.text = '0';
    }
  }
  
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
              SizedBox(height: size.height * 0.02),
              
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
              SizedBox(height: size.height * 0.02),
              
              // Location Type Selection
              DropdownButtonFormField<String>(
                borderRadius: BorderRadius.circular(16),
                value: _locationType,
                items: <String>['In-College', 'Outside College'].map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _locationType = newValue!;
                    // Reset fee if changing to In-College
                    if (_locationType == 'In-College') {
                      _feeController.text = '0';
                    } else {
                      _feeController.text = '';
                    }
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Location Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'Location Details',
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
              SizedBox(height: size.height * 0.02),
              
              // Fee input - disabled for in-college events
              TextFormField(
                controller: _feeController,
                enabled: _locationType == 'Outside College',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: _locationType == 'In-College' ? 'No Fee (In-College)' : 'Event Fee',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                ),
                validator: (value) {
                  if (_locationType == 'Outside College') {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a fee for outside events';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: size.height * 0.02),
              
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
              SizedBox(height: size.height * 0.02),
              
              // Start Date Selection
              ListTile(
                contentPadding: const EdgeInsets.only(left: 8, right: 8),
                title: const Text('Start Date'),
                subtitle: Text(
                  _selectedStartDate == null
                      ? 'Select Date'
                      : "${_selectedStartDate!.day}/${_selectedStartDate!.month}/${_selectedStartDate!.year}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now().add(const Duration(days: 1)),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null && pickedDate != _selectedStartDate) {
                    setState(() {
                      _selectedStartDate = pickedDate;
                      // Reset end date if it's before start date now
                      if (_selectedEndDate != null && _selectedEndDate!.isBefore(_selectedStartDate!)) {
                        _selectedEndDate = null;
                      }
                    });
                  }
                },
              ),
              SizedBox(height: size.height * 0.02),
              
              // End Date Selection
              ListTile(
                contentPadding: const EdgeInsets.only(left: 8, right: 8),
                title: const Text('End Date'),
                subtitle: Text(
                  _selectedEndDate == null
                      ? 'Select Date'
                      : "${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  if (_selectedStartDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a start date first')),
                    );
                    return;
                  }
                  
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedStartDate!,
                    firstDate: _selectedStartDate!,
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null && pickedDate != _selectedEndDate) {
                    setState(() {
                      _selectedEndDate = pickedDate;
                    });
                  }
                },
              ),
              SizedBox(height: size.height * 0.02),
              
              // Estimated Attendees Count
              TextFormField(
                controller: _attendeesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Estimated Number of Attendees',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter estimated attendees';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: size.height * 0.02),
              
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
              SizedBox(height: size.height * 0.02),
              
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
              SizedBox(height: size.height * 0.02),
              
              // Budget Estimation Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _selectedStartDate != null) {
                    _estimateBudget();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all required fields')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue.withOpacity(.8),
                ),
                child: isLoading && _showBudgetEstimate
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Estimate Budget'),
              ),
              SizedBox(height: size.height * 0.02),
              
              // Budget Estimation Display
              if (_estimatedBudget != null && _showBudgetEstimate)
                Card(
                  elevation: 4,
                  color: Colors.green.shade100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estimated Budget:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            // Display markdown text
                            Text(_estimatedBudget!),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            label: const Text("Confirm Budget", style: TextStyle(color: Colors.green)),
                            onPressed: () {
                              setState(() {
                                _budgetConfirmed = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Budget confirmed! You can now create the event.')),
                              );
                            },
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.refresh, color: Colors.blue),
                            label: const Text("Regenerate", style: TextStyle(color: Colors.blue)),
                            onPressed: () {
                              _estimateBudget();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              SizedBox(height: size.height * 0.02),
              
              // Create Event Button
              ElevatedButton(
                onPressed: (_budgetConfirmed || _estimatedBudget == null) ? _submitForm : null,
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: (_budgetConfirmed || _estimatedBudget == null) && _selectedStartDate != null
                        ? Colors.green.withOpacity(.8)
                        : Colors.green.withOpacity(.5)),
                child: isLoading && !_showBudgetEstimate
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _estimateBudget() async {
    if (_formKey.currentState!.validate() && _selectedStartDate != null) {
      setState(() {
        _showBudgetEstimate = true;
        isLoading = true;
        _budgetConfirmed = false; // Reset budget confirmation when regenerating
      });
      
      try {
        // Calculate event duration in days
        final int durationDays = _selectedEndDate != null
            ? _selectedEndDate!.difference(_selectedStartDate!).inDays + 1
            : 1;
        
        final int attendees = int.tryParse(_attendeesController.text) ?? 0;
        final double fee = double.tryParse(_feeController.text) ?? 0.0;
        
        // Call the Gemini API through our service
        final result = await _budgetService.estimateEventBudget(
          title: _titleController.text,
          description: _descriptionController.text,
          locationType: _locationType,
          locationDetails: _locationController.text,
          attendees: attendees,
          fee: fee,
          durationDays: durationDays,
        );
        
        setState(() {
          _estimatedBudget = result;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          _estimatedBudget = "Error generating budget estimate: $e";
          isLoading = false;
        });
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedStartDate != null) {
      // If budget is estimated but not confirmed, show a confirmation dialog
      if (_estimatedBudget != null && !_budgetConfirmed) {
        bool proceed = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Budget Not Confirmed"),
            content: const Text("You haven't confirmed the budget estimate. Do you want to proceed without it?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Proceed"),
              ),
            ],
          ),
        ) ?? false;
        
        if (!proceed) return;
      }
      
      Uuid uuid = const Uuid();
      var id = uuid.v4();
      setState(() {
        isLoading = true;
        _showBudgetEstimate = false;
      });
      
      try {
        // Calculate event duration
        final int durationDays = _selectedEndDate != null
            ? _selectedEndDate!.difference(_selectedStartDate!).inDays + 1
            : 1;
        
        final int attendees = int.tryParse(_attendeesController.text) ?? 0;
        final double fee = double.tryParse(_feeController.text) ?? 0.0;
        
        await FirebaseFirestore.instance.collection('events').doc(id).set({
          'id': id,
          'title': _titleController.text,
          'description': _descriptionController.text,
          'location': _locationController.text,
          'locationType': _locationType,
          'fee': fee,
          'startDate': _selectedStartDate,
          'endDate': _selectedEndDate ?? _selectedStartDate, // Default to start date if no end date
          'time': _timeController.text,
          'teamMembers': _selectedTeamMembers,
          'estimatedAttendees': attendees,
          'estimatedBudget': _estimatedBudget,
          'budgetConfirmed': _budgetConfirmed,
          'totalDays': durationDays,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _attendeesController.dispose();
    _feeController.dispose();
    super.dispose();
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