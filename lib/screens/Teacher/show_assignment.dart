import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/screens/Teacher/assignment_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/assignment.dart';

class ShowAssignment extends StatefulWidget {
  final String userId;
  const ShowAssignment({super.key, required this.userId});

  @override
  State<ShowAssignment> createState() => _ShowAssignmentState();
}

class _ShowAssignmentState extends State<ShowAssignment> {
  DateTime? tempDate;
  TextStyle subtitles = const TextStyle(
    fontWeight: FontWeight.w500,
    color: Colors.grey,
    fontSize: 12,
  );
  @override
  Widget build(BuildContext context) {
    TextEditingController desc = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    CollectionReference assignment =
        FirebaseFirestore.instance.collection('assignments');
    Widget appButton(
      Color? color,
      void Function() action,
      IconData icon,
      Text label,
      Color? fColor,
    ) {
      return TextButton.icon(
        onPressed: action,
        icon: Icon(
          icon,
          size: 18,
        ),
        label: label,
        style: ButtonStyle(
          padding: MaterialStateProperty.all(const EdgeInsets.all(8)),
          textStyle: MaterialStateProperty.all(const TextStyle(
            fontSize: 16,
          )),
          backgroundColor: MaterialStateProperty.all(color),
          foregroundColor: MaterialStateProperty.all(fColor ?? Colors.white),
        ),
      );
    }

    DateTime? currentDate;

    bool showLoading = false;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: assignment.where("id", isEqualTo: widget.userId).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Someing went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }

            var len = snapshot.data?.docs.length ?? 0;

            if (len < 1) {
              return const Center(
                child: Text("No assignments"),
              );
            } else {
              return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: len,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        snapshot.data!.docs[index];
                    Timestamp date = documentSnapshot["lastDate"] as Timestamp;
                    DateTime d = date.toDate();
                    Future<void> _selectDate(BuildContext context) async {
                      final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: d,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2050));
                      if (pickedDate != null && pickedDate != currentDate) {
                        setState(() {
                          currentDate = pickedDate;
                        });
                      }
                    }

                    final dateSelectionButton = Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(5),
                      color: const Color.fromARGB(255, 37, 37, 37),
                      child: MaterialButton(
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        minWidth: MediaQuery.of(context).size.width,
                        onPressed: () {
                          _selectDate(context);
                        },
                        child: Text(
                          currentDate != null
                              ? DateFormat('MMM d,yyyy')
                                  .format(currentDate ?? DateTime.now())
                              : "Select Last Date",
                          style: const TextStyle(
                              fontSize: 15.0, color: Colors.white),
                        ),
                      ),
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.grey.shade800 
                                : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ExpansionTile(
                            childrenPadding: EdgeInsets.zero,
                            collapsedBackgroundColor: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.grey.shade900 
                                : Colors.white,
                            backgroundColor: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.grey.shade800 
                                : Colors.grey.shade50,
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.deepPurple.withOpacity(0.2) 
                                    : Colors.deepPurple.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  _getAssignmentIcon(documentSnapshot),
                                  color: Colors.deepPurple,
                                  size: 20,
                                ),
                              ),
                            ),
                            textColor: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white 
                                : Colors.black87,
                            iconColor: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white 
                                : Colors.black87,
                            title: Text(
                              documentSnapshot["title"],
                              style: const TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.grey.shade400 
                                          : Colors.grey.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getDueDateStatus(d, context),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: _isDueDateNear(d) 
                                            ? Colors.orange 
                                            : (Theme.of(context).brightness == Brightness.dark 
                                                ? Colors.grey.shade400 
                                                : Colors.grey.shade700),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (documentSnapshot["subject"] != null)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.class_outlined,
                                        size: 14,
                                        color: Theme.of(context).brightness == Brightness.dark 
                                            ? Colors.grey.shade400 
                                            : Colors.grey.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          documentSnapshot["subject"],
                                        
                                          style: TextStyle(
                                            fontSize: 12,
                                            overflow: TextOverflow.ellipsis,
                                            color: Theme.of(context).brightness == Brightness.dark 
                                                ? Colors.grey.shade400 
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getBadgeColor(d, context),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getRemainingDays(d),
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.black 
                                          : Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              // Divider
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.grey.shade800 
                                    : Colors.grey.shade200,
                              ),
                              
                              // Description section
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Assignment Description',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).brightness == Brightness.dark 
                                            ? Colors.grey.shade300 
                                            : Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness == Brightness.dark 
                                            ? Colors.grey.shade800.withOpacity(0.5) 
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context).brightness == Brightness.dark 
                                              ? Colors.grey.shade700 
                                              : Colors.grey.shade300,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        documentSnapshot["desc"] ?? "No description provided",
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 1.5,
                                          color: Theme.of(context).brightness == Brightness.dark 
                                              ? Colors.white 
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    
                                    // Assignment metadata
                                    const SizedBox(height: 16),
                                    _buildAssignmentInfoRow(
                                      context: context,
                                      title: 'Subject',
                                      value: documentSnapshot["subject"] ?? "Not specified",
                                      icon: Icons.book,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildAssignmentInfoRow(
                                      context: context,
                                      title: 'Year',
                                      value: documentSnapshot["year"] ?? "Not specified",
                                      icon: Icons.school,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildAssignmentInfoRow(
                                      context: context,
                                      title: 'Date Posted',
                                      value: _formatTimestamp(documentSnapshot["assignedDate"] as Timestamp),
                                      icon: Icons.upload_file,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildAssignmentInfoRow(
                                      context: context,
                                      title: 'Due Date',
                                      value: DateFormat('EEEE, MMM d, yyyy').format(d),
                                      icon: Icons.event_available,
                                      highlight: true,
                                    ),
                                    
                                    // File/Attachment indicator
                                    if (documentSnapshot["url"] != null && documentSnapshot["url"] is String && (documentSnapshot["url"] as String).isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.blue.withOpacity(0.1)
                                                : Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.blue.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.attachment,
                                                color: Colors.blue.shade400,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Assignment File Attached',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Theme.of(context).brightness == Brightness.dark
                                                            ? Colors.blue.shade300
                                                            : Colors.blue.shade700,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      _getFileNameFromUrl(documentSnapshot["url"]),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Theme.of(context).brightness == Brightness.dark
                                                            ? Colors.grey.shade300
                                                            : Colors.grey.shade700,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () => _openFile(documentSnapshot["url"]),
                                                icon: Icon(
                                                  Icons.open_in_new,
                                                  color: Colors.blue.shade400,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              
                              // Action buttons row
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade900
                                      : Colors.white,
                                  border: Border(
                                    top: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.grey.shade800 
                                          : Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Edit Button
                                    _buildActionButton(
                                      context: context,
                                      icon: Icons.edit_outlined,
                                      label: 'Edit',
                                      color: Colors.blue.shade700,
                                      onPressed: () {
                                        _showEditAssignmentDialog(context, documentSnapshot);
                                      },
                                    ),
                                    
                                    // Delete Button
                                    _buildActionButton(
                                      context: context,
                                      icon: Icons.delete_outline,
                                      label: 'Delete',
                                      color: Colors.red.shade700,
                                      onPressed: () {
                                        _showDeleteConfirmationDialog(context, documentSnapshot);
                                      },
                                    ),
                                    
                                    // View Submissions Button
                                    _buildActionButton(
                                      context: context,
                                      icon: Icons.assignment_turned_in_outlined,
                                      label: 'Submissions',
                                      color: Colors.green.shade700,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AssignmentResponse(
                                              id: documentSnapshot["assignmentId"] ?? ""
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            }
          }),
    );
  }
}

// Helper methods to put outside the build method

// Get appropriate icon for assignment type
IconData _getAssignmentIcon(DocumentSnapshot doc) {
  // You can customize this based on assignment properties
  final subject = doc["subject"] as String? ?? "";
  
  if (subject.toLowerCase().contains("math")) {
    return Icons.calculate;
  } else if (subject.toLowerCase().contains("comput") || 
             subject.toLowerCase().contains("program")) {
    return Icons.computer;
  } else if (subject.toLowerCase().contains("science")) {
    return Icons.science;
  } else if (subject.toLowerCase().contains("engin")) {
    return Icons.engineering;
  } else {
    return Icons.assignment;
  }
}

// Helper to format timestamp
String _formatTimestamp(Timestamp timestamp) {
  final date = timestamp.toDate();
  return DateFormat('MMM d, yyyy').format(date);
}

// Helper to get file name from URL
String _getFileNameFromUrl(String url) {
  if (url.isEmpty) return "";
  try {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      // Try to decode the filename if it's URL encoded
      final lastSegment = pathSegments.last;
      return Uri.decodeComponent(lastSegment);
    }
  } catch (e) {
    // If parsing fails, try a simpler approach
    final parts = url.split('/');
    if (parts.isNotEmpty) {
      return parts.last;
    }
  }
  return "Download File";
}

// Open file in browser or dedicated viewer
void _openFile(String url) async {
  // Implement file opening logic
  // You might want to use url_launcher package
  print("Opening file: $url");
  // if (await canLaunch(url)) {
  //   await launch(url);
  // }
}

// Create info row for assignment metadata
Widget _buildAssignmentInfoRow({
  required BuildContext context, 
  required String title, 
  required String value, 
  required IconData icon, 
  bool highlight = false,
}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        icon,
        size: 16,
        color: highlight 
            ? Colors.deepPurple
            : (isDarkMode ? Colors.grey.shade500 : Colors.grey.shade700),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                overflow: TextOverflow.ellipsis,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
                color: highlight 
                    ? (isDarkMode ? Colors.deepPurple.shade300 : Colors.deepPurple) 
                    : (isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// Check if due date is near (within 2 days)
bool _isDueDateNear(DateTime dueDate) {
  final now = DateTime.now();
  final difference = dueDate.difference(now);
  return difference.inDays < 3 && difference.inDays >= 0;
}

// Get due date status text
String _getDueDateStatus(DateTime dueDate, BuildContext context) {
  final now = DateTime.now();
  final difference = dueDate.difference(now);
  
  if (difference.inDays < 0) {
    return "Due date passed";
  } else if (difference.inDays == 0) {
    return "Due today";
  } else if (difference.inDays == 1) {
    return "Due tomorrow";
  } else {
    return "Due on ${DateFormat('MMM d').format(dueDate)}";
  }
}

// Get remaining days text
String _getRemainingDays(DateTime dueDate) {
  final now = DateTime.now();
  final difference = dueDate.difference(now);
  
  if (difference.inDays < 0) {
    return "Overdue";
  } else if (difference.inDays == 0) {
    return "Today";
  } else if (difference.inDays == 1) {
    return "1 day left";
  } else {
    return "${difference.inDays} days left";
  }
}

// Get badge color based on due date
Color _getBadgeColor(DateTime dueDate, BuildContext context) {
  final now = DateTime.now();
  final difference = dueDate.difference(now);
  
  if (difference.inDays < 0) {
    return Colors.red;
  } else if (difference.inDays < 3) {
    return Colors.orange;
  } else {
    return Colors.green;
  }
}

// Action button builder
Widget _buildActionButton({
  required BuildContext context,
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onPressed,
}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return Expanded(
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isDarkMode ? color.withOpacity(0.8) : color,
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode 
                      ? Colors.grey.shade300 
                      : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class AlertForDelete extends StatefulWidget {
  final String assignmentId;
  final CollectionReference assignment;
  const AlertForDelete(
      {super.key, required this.assignment, required this.assignmentId});

  @override
  State<AlertForDelete> createState() => _AlertForDeleteState();
}

class _AlertForDeleteState extends State<AlertForDelete> {
  @override
  Widget build(BuildContext context) {
    Widget appButton(
      Color? color,
      Function action,
      Icon icon,
      Text label,
    ) {
      return TextButton.icon(
        onPressed: () {
          action;
        },
        icon: icon,
        label: label,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(color),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        ),
      );
    }

    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 37, 37, 37),
      contentPadding: const EdgeInsets.all(12.0),
      title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Are you sure ?",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            CloseButton(),
          ]),
      content: const Text(
          "This will delete the assignment from database for ever!!"),
      actions: [
        appButton(
          Colors.black,
          () {
            Navigator.pop(context);
          },
          const Icon(Icons.cancel),
          const Text("Cancel"),
        ),
        appButton(
          Colors.black,
          () {
            widget.assignment.doc(widget.assignmentId).delete().then(
              (value) {
                print("Deleted Succefully");
                Navigator.pop(context);
              },
            );
          },
          const Icon(Icons.delete_forever),
          const Text("Delete"),
        )
      ],
    );
  }
}

void _showEditAssignmentDialog(BuildContext context, DocumentSnapshot documentSnapshot) {
  final _formKey = GlobalKey<FormState>();
  String? title;
  String? descriptionX;
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  Timestamp date = documentSnapshot["lastDate"] as Timestamp;
  DateTime d = date.toDate();
  DateTime? currentDate;

  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? Colors.blue.withOpacity(0.2) 
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.edit_document,
                            color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Edit Assignment",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                
                // Assignment title
                Text(
                  "Title",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                
                TextFormField(
                  initialValue: documentSnapshot["title"],
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDarkMode ? Colors.blue.shade400 : Colors.blue.shade700,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.red.shade300,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    hintText: "Enter assignment title",
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    title = value;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Assignment description
                Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                
                TextFormField(
                  initialValue: documentSnapshot["desc"],
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDarkMode ? Colors.blue.shade400 : Colors.blue.shade700,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    hintText: "Enter assignment description",
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
                    ),
                  ),
                  maxLines: 5,
                  minLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    descriptionX = value;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Due date
                Text(
                  "Due Date",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Date selection field
                InkWell(
                  onTap: () async {
                    // Date picker
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: d,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2050),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Colors.blue.shade700,
                              onPrimary: Colors.white,
                              onSurface: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            dialogBackgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                          ),
                          child: child!,
                        );
                      },
                    );
                    
                    if (pickedDate != null && context.mounted) {
                      Navigator.of(context).pop();
                      _showEditAssignmentDialog(context, documentSnapshot);
                      currentDate = pickedDate;
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            currentDate != null
                                ? DateFormat('EEEE, MMM d, yyyy').format(currentDate!)
                                : DateFormat('EEEE, MMM d, yyyy').format(d),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Current assignment file indicator
                if (documentSnapshot["url"] != null && documentSnapshot["url"] is String && (documentSnapshot["url"] as String).isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.blueGrey.withOpacity(0.2)
                          : Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDarkMode ? Colors.blueGrey.shade700 : Colors.blueGrey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.insert_drive_file_outlined,
                          size: 18,
                          color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Current File",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getFileNameFromUrl(documentSnapshot["url"]),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text(
                        "CANCEL",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Update button
                    ElevatedButton(
                      onPressed: () {
                        final isValid = _formKey.currentState!.validate();
                        
                        if (isValid) {
                          _updateAssignment(
                            context: context, 
                            documentSnapshot: documentSnapshot, 
                            title: title, 
                            description: descriptionX, 
                            dueDate: currentDate ?? d
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? Colors.blue.shade700 : Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.save_outlined, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            "SAVE CHANGES",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// Helper method to update assignment
void _updateAssignment({
  required BuildContext context,
  required DocumentSnapshot documentSnapshot,
  String? title,
  String? description,
  required DateTime dueDate,
}) {
  final CollectionReference assignment = FirebaseFirestore.instance.collection('assignments');
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              "Updating assignment...",
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  // Create updated assignment model
  AssignMentModel assignmentX = AssignMentModel();
  assignmentX.id = documentSnapshot["id"];
  assignmentX.desc = description ?? documentSnapshot["desc"];
  assignmentX.title = title ?? documentSnapshot["title"];
  assignmentX.assignedBy = documentSnapshot["assignedBy"];
  assignmentX.url = documentSnapshot["url"];
  assignmentX.subject = documentSnapshot["subject"];
  
  // Handle assigned date
  if (documentSnapshot["assignedDate"] is Timestamp) {
    Timestamp date = documentSnapshot["assignedDate"] as Timestamp;
    DateTime ad = date.toDate();
    assignmentX.assignedDate = ad;
  } else {
    assignmentX.assignedDate = DateTime.now();
  }
  
  assignmentX.lastDate = dueDate;
  assignmentX.toBranch = documentSnapshot["toBranch"];
  assignmentX.year = documentSnapshot["year"];
  assignmentX.assignmentId = documentSnapshot["assignmentId"];

  // Update in Firestore
  assignment
    .doc(documentSnapshot["assignmentId"])
    .update(assignmentX.toMap())
    .then((value) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Close edit dialog
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Assignment updated successfully',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      );
    })
    .catchError((error) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Failed to update assignment: $error',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
}

void _showDeleteConfirmationDialog(BuildContext context, DocumentSnapshot documentSnapshot) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final CollectionReference assignment = FirebaseFirestore.instance.collection('assignments');
  
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with warning icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? Colors.red.withOpacity(0.2) 
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red.shade400,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Delete Assignment",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Warning message
            Text(
              "Are you sure you want to delete this assignment?",
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Assignment details summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documentSnapshot["title"] ?? "Untitled Assignment",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.class_outlined,
                        size: 14,
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          documentSnapshot["subject"] ?? "No subject",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Warning about consequences
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.red.shade900.withOpacity(0.2)
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.shade300.withOpacity(isDarkMode ? 0.3 : 1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.delete_forever,
                      color: Colors.red.shade300,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "This action cannot be undone. All student submissions for this assignment will also be deleted.",
                      style: TextStyle(
                        color: isDarkMode ? Colors.red.shade300 : Colors.red.shade900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel button
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                    side: BorderSide(
                      color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text(
                    "CANCEL",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Delete button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    
                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                "Deleting assignment...",
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    
                    // Perform deletion
                    assignment
                      .doc(documentSnapshot["assignmentId"])
                      .delete()
                      .then((value) {
                        // Close loading dialog
                        Navigator.of(context).pop();
                        
                        // Show success notification
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle_outline, color: Colors.white),
                                SizedBox(width: 16),
                                Text(
                                  'Assignment deleted successfully',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        );
                      })
                      .catchError((error) {
                        // Close loading dialog
                        Navigator.of(context).pop();
                        
                        // Show error notification
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.white),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Error deleting assignment: $error',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.red.shade700,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text(
                    "DELETE",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
