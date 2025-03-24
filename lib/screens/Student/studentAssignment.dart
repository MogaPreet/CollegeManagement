import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/assignment.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/Student/studentHome.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class ShowAssignments extends StatefulWidget {
  final AssignMentModel assigment;
  final String rollNo;
  final String userId;

  const ShowAssignments({
    super.key,
    required this.assigment,
    required this.rollNo,
    required this.userId,
  });

  @override
  State<ShowAssignments> createState() => _ShowAssignmentsState();
}

class _ShowAssignmentsState extends State<ShowAssignments> {
  UploadTask? task;
  File? file;
  String? url1;
  bool isLoading = false;
  bool _uploadStarted = false;
  bool _showFilePreview = true;
  double _uploadProgress = 0.0;
  String _fileSize = '';
  String _fileName = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _checkSubmissionStatus();
  }

  Future<bool> _checkSubmissionStatus() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('assignments')
          .doc(widget.assigment.assignmentId)
          .collection('responses')
          .doc(widget.rollNo)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<void> selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result == null) return;

      final path = result.files.single.path!;
      final file = File(path);

      // Calculate file size
      final bytes = await file.length();
      final kb = bytes / 1024;
      final mb = kb / 1024;

      setState(() {
        this.file = file;
        _showFilePreview = true;
        _fileName = p.basename(path);
        _fileSize = mb > 1
            ? '${mb.toStringAsFixed(2)} MB'
            : '${kb.toStringAsFixed(2)} KB';
      });
    } catch (e) {
      _showErrorSnackbar("Error selecting file: ${e.toString()}");
    }
  }

  Future<void> uploadFile() async {
    if (file == null) {
      _showErrorSnackbar("Please select a file first");
      return;
    }

    setState(() {
      _uploadStarted = true;
      isLoading = true;
    });

    try {
      final Uuid randId = const Uuid();
      final fileName =
          '${widget.rollNo}_${DateTime.now().millisecondsSinceEpoch}${p.extension(file!.path)}';
      final destination =
          'files/assignments/${widget.assigment.assignmentId}/$fileName';

      task = FirebaseApi.uploadFile(destination, file!);

      if (task == null) {
        _showErrorSnackbar("Could not upload file. Please try again.");
        setState(() {
          isLoading = false;
          _uploadStarted = false;
        });
        return;
      }

      // Listen to upload progress
      task!.snapshotEvents.listen((snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      final snapshot = await task!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();

      setState(() {
        url1 = urlDownload;
        isLoading = false;
      });

      // Submit the assignment
      _submitAssignment();
    } catch (e) {
      setState(() {
        isLoading = false;
        _uploadStarted = false;
      });
      _showErrorSnackbar("Error uploading file: ${e.toString()}");
    }
  }

  void _submitAssignment() async {
    if (url1 == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      String assignmentId = widget.assigment.assignmentId ?? "";

      // Create assignment response model
      AssignmentResponseModel assignment = AssignmentResponseModel();
      assignment.id = widget.userId;
      assignment.assignedDate =
          widget.assigment.getAssignDate?.toDate() ?? DateTime.now();
      assignment.submittedDate = DateTime.now();
      assignment.url = url1;
      assignment.status = "submitted";
      assignment.assignmentId = assignmentId;
      assignment.rollNo = widget.rollNo;

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection("assignments")
          .doc(assignmentId)
          .collection("responses")
          .doc(widget.rollNo)
          .set(assignment.toMap());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Assignment submitted successfully!"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ));

      // Navigate back to home
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const StudentHomePage()),
          (route) => false);
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackbar("Error submitting assignment: ${error.toString()}");
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
    ));
  }

  Future<void> _launchUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackbar("Could not open the document");
      }
    } catch (e) {
      _showErrorSnackbar("Error opening document: ${e.toString()}");
    }
  }

  Widget _buildFilePreview() {
    if (file == null || !_showFilePreview) return const SizedBox.shrink();

    final extension = p.extension(file!.path).toLowerCase();
    final isImage = ['.jpg', '.jpeg', '.png'].contains(extension);
    final isPdf = extension == '.pdf';
    final isDoc = ['.doc', '.docx'].contains(extension);

    Color cardColor;
    IconData fileIcon;
    Color iconColor;

    // Determine file type styling
    if (isImage) {
      cardColor = Colors.blue.shade50;
      fileIcon = Icons.image_rounded;
      iconColor = Colors.blue.shade700;
    } else if (isPdf) {
      cardColor = Colors.red.shade50;
      fileIcon = Icons.picture_as_pdf_rounded;
      iconColor = Colors.red.shade700;
    } else if (isDoc) {
      cardColor = Colors.indigo.shade50;
      fileIcon = Icons.description_rounded;
      iconColor = Colors.indigo.shade700;
    } else {
      cardColor = Colors.grey.shade100;
      fileIcon = Icons.insert_drive_file_rounded;
      iconColor = Colors.grey.shade700;
    }

    return Card(
      margin: const EdgeInsets.only(top: 20),
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: iconColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  fileIcon,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Selected File',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: iconColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: iconColor,
                  onPressed: () => setState(() {
                    file = null;
                  }),
                ),
              ],
            ),
          ),

          // File content
          if (isImage)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Image.file(
                file!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: iconColor.withOpacity(0.2)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fileName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _fileSize,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: selectFile,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Change File'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      backgroundColor: iconColor,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUploadStatus() {
    if (!_uploadStarted) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uploading file...',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final DateTime? dueDate = widget.assigment.getLastDate?.toDate();
    final DateTime? assignedDate = widget.assigment.getAssignDate?.toDate();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey.shade50,
      // Enhanced AppBar with better styling and subject tag
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? Colors.grey.shade900
            : const Color.fromARGB(255, 37, 37, 37),
        elevation: 4,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20,color: Colors.white,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Assignment Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white
              ),
            ),
            const SizedBox(height: 2),
            // Subject is now shown as a subtitle in the AppBar
            Text(
              widget.assigment.subject ?? "No Subject",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          FutureBuilder<bool>(
            future: _checkSubmissionStatus(),
            builder: (context, snapshot) {
              final bool isSubmitted = snapshot.data ?? false;

              return isSubmitted
                  ? Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "Submitted",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.pending_outlined,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "Pending",
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
            },
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.blue.shade700, Colors.purple.shade700]
                    : [Colors.blue.shade400, Colors.purple.shade400],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            children: [
              // Assignment Header
              Text(
                widget.assigment.title ?? "Untitled Assignment",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              // Teacher info (Subject is now in the AppBar)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: isDarkMode
                          ? Colors.amber.shade300
                          : Colors.amber.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Assigned by: ${widget.assigment.assignedBy ?? "Unknown"}",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Rest of the content remains the same...
              // Due date and timeline
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey.shade900.withOpacity(0.5)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade300,
                  ),
                  boxShadow: isDarkMode
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Assigned',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                assignedDate != null
                                    ? DateFormat('MMM d, yyyy')
                                        .format(assignedDate)
                                    : 'Not specified',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Due Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dueDate != null
                                    ? DateFormat('MMM d, yyyy').format(dueDate)
                                    : 'No deadline',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Timeline indicator
                    if (dueDate != null && assignedDate != null)
                      FutureBuilder<bool>(
                        future: _checkSubmissionStatus(),
                        builder: (context, snapshot) {
                          final isSubmitted = snapshot.data ?? false;
                          final now = DateTime.now();
                          final totalDuration =
                              dueDate.difference(assignedDate).inDays;
                          final elapsedDuration =
                              now.difference(assignedDate).inDays;
                          double progress = totalDuration > 0
                              ? elapsedDuration / totalDuration
                              : 1.0;

                          // Clamp progress to 0.0-1.0
                          progress = progress.clamp(0.0, 1.0);

                          Color progressColor;
                          if (isSubmitted) {
                            progressColor = Colors.green;
                          } else if (now.isAfter(dueDate)) {
                            progressColor = Colors.red;
                          } else if (progress > 0.75) {
                            progressColor = Colors.orange;
                          } else {
                            progressColor = Colors.blue;
                          }

                          String statusText;
                          if (isSubmitted) {
                            statusText = "Submitted";
                          } else if (now.isAfter(dueDate)) {
                            statusText = "Overdue";
                          } else if (now.day == dueDate.day &&
                              now.month == dueDate.month &&
                              now.year == dueDate.year) {
                            statusText = "Due today";
                          } else {
                            final daysLeft = dueDate.difference(now).inDays;
                            statusText = "Due in $daysLeft days";
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    progressColor),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progress',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkMode
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: progressColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color:
                                              progressColor.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: progressColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),

              // Description and other existing content remains the same...
              const SizedBox(height: 24),

              // Description
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey.shade900.withOpacity(0.5)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade300,
                  ),
                  boxShadow: isDarkMode
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Text(
                  widget.assigment.desc ?? "No description provided",
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: isDarkMode
                        ? Colors.grey.shade300
                        : Colors.grey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Reference document
              if (widget.assigment.url != null &&
                  widget.assigment.url!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reference Material',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey.shade900.withOpacity(0.5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                        ),
                        boxShadow: isDarkMode
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _launchUrl(widget.assigment.url!),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.description_outlined,
                                    color: Colors.indigo,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'View Document',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tap to open reference material',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDarkMode
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.open_in_new_rounded,
                                  color: isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade700,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // Your submission
              Text(
                'Your Submission',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // File selection
              FutureBuilder<bool>(
                future: _checkSubmissionStatus(),
                builder: (context, snapshot) {
                  final bool alreadySubmitted = snapshot.data ?? false;

                  if (alreadySubmitted) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.3)),
                        boxShadow: isDarkMode
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Assignment Submitted',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your assignment has been submitted and is being reviewed.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey.shade900.withOpacity(0.5)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade300,
                          ),
                          boxShadow: isDarkMode
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: selectFile,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 16),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.upload_file_rounded,
                                      color: Colors.indigo,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    file != null
                                        ? 'Change File'
                                        : 'Upload Your Assignment',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'PDF, Word or Image files (Max 10MB)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDarkMode
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // File preview
                      _buildFilePreview(),

                      // Upload progress
                      _buildUploadStatus(),
                    ],
                  );
                },
              ),

              // Add some extra space at the bottom
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      // Enhanced bottom action bar
      bottomNavigationBar: FutureBuilder<bool>(
        future: _checkSubmissionStatus(),
        builder: (context, snapshot) {
          final bool alreadySubmitted = snapshot.data ?? false;

          // Calculate padding to account for safe area
          final bottomPadding = MediaQuery.of(context).padding.bottom;

          return Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomPadding),
            child: alreadySubmitted
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Submitted Successfully",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "You'll be notified when graded",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          foregroundColor:
                              isDarkMode ? Colors.white : Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: const Text("Back"),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed:
                        isLoading || file == null ? null : () => uploadFile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 37, 37, 37),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: isDarkMode
                          ? Colors.grey.shade800.withOpacity(0.5)
                          : Colors.grey.shade300,
                      disabledForegroundColor: isDarkMode
                          ? Colors.grey.shade600
                          : Colors.grey.shade600,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 54),
                    ),
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white.withOpacity(0.8),
                                  strokeWidth: 2.5,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Submitting...",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                file == null
                                    ? Icons.file_upload_outlined
                                    : Icons.check_circle_outline,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                file == null
                                    ? "Select a File to Submit"
                                    : "Submit Assignment",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
          );
        },
      ),
    );
  }
}

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      return ref.putFile(file);
    } on FirebaseException {
      return null;
    }
  }
}
