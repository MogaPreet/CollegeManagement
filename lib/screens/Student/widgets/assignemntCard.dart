import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/assignment.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/Student/studentAssignment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentAssignmentCard extends StatefulWidget {
  final StudentModel student;
  const StudentAssignmentCard({super.key, required this.student});

  @override
  State<StudentAssignmentCard> createState() => _StudentAssignmentCardState();
}

class _StudentAssignmentCardState extends State<StudentAssignmentCard> {
  @override
  Widget build(BuildContext context) {
    final CollectionReference assignmentsRef = 
        FirebaseFirestore.instance.collection('assignments');
        
    return StreamBuilder<QuerySnapshot>(
      stream: assignmentsRef
          .where("toBranch", isEqualTo: widget.student.branch)
          .where("year", isEqualTo: widget.student.currentYear)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState();
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }
        
        final assignments = snapshot.data?.docs ?? [];
        
        if (assignments.isEmpty) {
          return _buildEmptyState();
        }
        
        return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: assignments.length,
          itemBuilder: ((context, index) {
            final assignment = AssignMentModel.fromMap(assignments[index]);
            return EnhancedAssignmentCard(
              assignment: assignment,
              rollNo: widget.student.rollNo ?? "",
              studentId: widget.student.uid ?? "",
              colref: assignmentsRef,
            );
          }),
        );
      },
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t load your assignments. Please try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24, 
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 3,
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            height: 160,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 100,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 200,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Assignments Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have any assignments at the moment. Enjoy your free time!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EnhancedAssignmentCard extends StatefulWidget {
  final AssignMentModel assignment;
  final String studentId;
  final String rollNo;
  final CollectionReference colref;
  
  const EnhancedAssignmentCard({
    Key? key,
    required this.assignment,
    required this.studentId,
    required this.rollNo,
    required this.colref,
  }) : super(key: key);

  @override
  State<EnhancedAssignmentCard> createState() => _EnhancedAssignmentCardState();
}

class _EnhancedAssignmentCardState extends State<EnhancedAssignmentCard> {
  AssignmentResponseModel assignmentRes = AssignmentResponseModel();
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _fetchAssignmentStatus();
  }
  
  Future<void> _fetchAssignmentStatus() async {
    try {
      final doc = await widget.colref
          .doc(widget.assignment.assignmentId)
          .collection("responses")
          .doc(widget.rollNo)
          .get();
          
      if (doc.exists && doc.data() != null) {
        assignmentRes = AssignmentResponseModel.fromMap(doc);
      }
    } catch (e) {
      // Handle error silently
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  
  Color _getStatusColor() {
    if (assignmentRes.status == null || assignmentRes.status!.isEmpty) {
      return Colors.orange; // Pending
    }
    
    switch (assignmentRes.status!.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'submitted':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText() {
    if (assignmentRes.status == null || assignmentRes.status!.isEmpty) {
      final dueInDays = _getDaysRemaining();
      if (dueInDays < 0) {
        return "Overdue";
      } else if (dueInDays == 0) {
        return "Due today";
      } else {
        return "Due in $dueInDays days";
      }
    }
    
    return assignmentRes.status!;
  }
  
  int _getDaysRemaining() {
    if (widget.assignment.getLastDate == null) return 0;
    
    final dueDate = widget.assignment.getLastDate!.toDate();
    final today = DateTime.now();
    
    final difference = DateTime(dueDate.year, dueDate.month, dueDate.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
        
    return difference;
  }
  
  bool _isOverdue() {
    return _getDaysRemaining() < 0;
  }
  
  bool _isDueToday() {
    return _getDaysRemaining() == 0;
  }
  
  bool _isCompleted() {
    return assignmentRes.status?.toLowerCase() == 'accepted';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final DateTime? dueDate = widget.assignment.getLastDate?.toDate();
    final DateTime? assignedDate = widget.assignment.getAssignDate?.toDate();
    final int daysRemaining = _getDaysRemaining();
    final bool canOpen = assignmentRes.status?.toLowerCase() != "accepted";
    
    final Color cardColor = isDarkMode 
        ? (_isCompleted() 
            ? Colors.green.shade900.withOpacity(0.2)
            : (_isOverdue() 
                ? Colors.red.shade900.withOpacity(0.2)
                : Colors.grey.shade900))
        : (_isCompleted() 
            ? Colors.green.shade50
            : (_isOverdue() 
                ? Colors.red.shade50
                : Colors.white));
                
    final Color statusColor = _getStatusColor();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _isOverdue() && !_isCompleted() 
              ? Colors.red.withOpacity(0.5) 
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      elevation: 2,
      color: cardColor,
      child: InkWell(
        onTap: canOpen ? () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => ShowAssignments(
                assigment: widget.assignment,
                rollNo: widget.rollNo,
                userId: widget.studentId,
              ),
            ),
          );
        } : null,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Status indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: statusColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                  const Spacer(),
                  if (_isDueToday() && !_isCompleted())
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, 
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Due Today',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assignment details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and subject
                        Text(
                          widget.assignment.title ?? "Untitled Assignment",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.assignment.subject ?? "No Subject",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Due date
                        Row(
                          children: [
                            Icon(
                              Icons.event_rounded,
                              size: 16,
                              color: _isOverdue() && !_isCompleted()
                                  ? Colors.red
                                  : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dueDate != null
                                  ? 'Due: ${DateFormat('MMM d, yyyy').format(dueDate)}'
                                  : 'No due date',
                              style: TextStyle(
                                fontSize: 14,
                                color: _isOverdue() && !_isCompleted()
                                    ? Colors.red
                                    : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Assigned by and date
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 16,
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                widget.assignment.assignedBy ?? "Unknown Teacher",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (assignedDate != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Assigned: ${DateFormat('MMM d, yyyy').format(assignedDate)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Status indicator or action button
                  _buildStatusIndicator(isDarkMode),
                ],
              ),
            ),
            
            // Actions or info footer
            if (!_isCompleted() && canOpen)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black12 : Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View assignment details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusIndicator(bool isDarkMode) {
    if (_isCompleted()) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(isDarkMode ? 0.2 : 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_circle_outline_rounded,
          color: isDarkMode ? Colors.green.shade300 : Colors.green.shade700,
          size: 28,
        ),
      );
    } else if (assignmentRes.status?.toLowerCase() == 'submitted') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(isDarkMode ? 0.2 : 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.watch_later_outlined,
          color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
          size: 28,
        ),
      );
    } else if (_isOverdue()) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(isDarkMode ? 0.2 : 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.warning_rounded,
          color: isDarkMode ? Colors.red.shade300 : Colors.red.shade700,
          size: 28,
        ),
      );
    } else if (_isDueToday()) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(isDarkMode ? 0.2 : 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.notifications_active_rounded,
          color: isDarkMode ? Colors.orange.shade300 : Colors.orange.shade700,
          size: 28,
        ),
      );
    } else {
      // Regular pending assignment
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(isDarkMode ? 0.2 : 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.assignment_outlined,
          color: isDarkMode ? Colors.purple.shade300 : Colors.purple.shade700,
          size: 28,
        ),
      );
    }
  }
}