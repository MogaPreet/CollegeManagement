import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/notice.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/Teacher/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final isOptionSelected = StateProvider.autoDispose((ref) => false);

class Notice extends ConsumerStatefulWidget {
  final TeacherModel notifier;
  const Notice({super.key, required this.notifier});

  @override
  ConsumerState<Notice> createState() => _NoticeState();
}

class _NoticeState extends ConsumerState<Notice> {
  final _formKey = GlobalKey<FormState>();
  String? url;
  final noticeTitleController = TextEditingController();
  final noticeDescController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSubmitting = false;

  @override
  void dispose() {
    noticeTitleController.dispose();
    noticeDescController.dispose();
    super.dispose();
  }

  Future<void> addNotice() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    _formKey.currentState!.save();
    
    try {
      final currentSelection = ref.read(isOptionSelected);
      
      List<String> branch = [
        'Artificial Intelligence & Data Science',
        'Civil Engineering',
        'Computer Engineering',
        'Electrical Engineering',
        'Electronics Engineering',
        'Information Technology',
        'Mechanical Engineering'
      ];
      
      List<String> currentb = widget.notifier.branch ?? [];
      List<String> targetBranches = currentSelection ? branch : currentb;
      
      NoticeModel notice = NoticeModel();
      notice.id = int.tryParse(widget.notifier.uid ?? "");
      notice.notifiedBy = widget.notifier.firstName;
      notice.title = noticeTitleController.text.trim();
      notice.desc = noticeDescController.text.trim();
      notice.url = "";
      notice.toBranch = targetBranches;
      notice.createdAt = Timestamp.now().toDate().toString();
      
      await FirebaseFirestore.instance
          .collection('notices')
          .doc()
          .set(notice.toMap());
          
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notice added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TeacherHome()),
      );
    } catch (error) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error posting notice: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentSelection = ref.watch(isOptionSelected);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
        elevation: 0,
        title: Text(
          'Create Notice',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Main content area with form fields
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Header with info
                      _buildInfoCard(isDarkMode),
                      
                      const SizedBox(height: 24),
                      
                      // Notice title
                      Text(
                        'Notice Title',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTitleField(isDarkMode),
                      
                      const SizedBox(height: 24),
                      
                      // Notice description
                      Text(
                        'Notice Content',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDescriptionField(isDarkMode),
                      
                      const SizedBox(height: 24),
                      
                      // Notice visibility
                      Card(
                        elevation: 0,
                        color: isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notice Visibility',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SwitchListTile(
                                title: const Text('Send to all branches'),
                                subtitle: Text(
                                  currentSelection 
                                      ? 'Notice will be visible to all branches' 
                                      : 'Notice will only be visible to your branches',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                ),
                                value: currentSelection,
                                activeColor: Colors.deepPurple,
                                contentPadding: EdgeInsets.zero,
                                onChanged: (value) {
                                  ref.read(isOptionSelected.notifier).state = value;
                                },
                              ),
                              
                              const SizedBox(height: 8),
                              
                              Text(
                                currentSelection
                                    ? 'Target: All Branches'
                                    : 'Target: ${(widget.notifier.branch ?? []).join(", ")}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                
                // Submit button at bottom
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : addNotice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.deepPurple.withOpacity(0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Post Notice',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoCard(bool isDarkMode) {
    return Card(
      elevation: 0,
      color: isDarkMode
          ? Colors.deepPurple.withOpacity(0.2)
          : Colors.deepPurple.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline,
                color: Colors.deepPurple,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Creating a new notice',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This notice will be visible to students in the selected branches',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
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
  
  Widget _buildTitleField(bool isDarkMode) {
    return TextFormField(
      controller: noticeTitleController,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: 'Enter notice title',
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
        prefixIcon: Icon(
          Icons.title_rounded,
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
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
          borderSide: const BorderSide(
            color: Colors.deepPurple,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red.shade300,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Notice title is required';
        }
        if (value.length < 5) {
          return 'Title should be at least 5 characters';
        }
        return null;
      },
    );
  }
  
  Widget _buildDescriptionField(bool isDarkMode) {
    return TextFormField(
      controller: noticeDescController,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: 'Enter notice content...',
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
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
          borderSide: const BorderSide(
            color: Colors.deepPurple,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red.shade300,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Notice content is required';
        }
        if (value.length < 10) {
          return 'Content should be at least 10 characters';
        }
        return null;
      },
      maxLines: 8,
      minLines: 5,
      textAlignVertical: TextAlignVertical.top,
    );
  }
}