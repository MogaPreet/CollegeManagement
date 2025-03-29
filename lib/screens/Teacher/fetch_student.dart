import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/models/user.dart';

// Year selection provider
final currentYear = StateProvider<String>((ref) => 'First Year');

class FetchStudent extends ConsumerStatefulWidget {
  final List<String> myBranch;
  const FetchStudent({super.key, required this.myBranch});

  @override
  ConsumerState<FetchStudent> createState() => _FetchStudentState();
}

class _FetchStudentState extends ConsumerState<FetchStudent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedBranch;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.myBranch.isNotEmpty) {
      _selectedBranch = widget.myBranch.first;
    }
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final selectedYear = ref.watch(currentYear);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    
    return Column(
      children: [
        // Top controls section
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Students',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // Search and filter section
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search students...',
                        hintStyle: TextStyle(
                          color: subtitleColor,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: subtitleColor,
                        ),
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _showFilterDialog(context);
                      },
                      icon: Icon(
                        Icons.filter_list,
                        color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                      ),
                      tooltip: 'Filter',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Year selector chips
              YearSelector(selectedYear: selectedYear),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Selected branch indicator
        if (_selectedBranch != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.corporate_fare,
                  size: 16,
                  color: subtitleColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Branch: $_selectedBranch',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: subtitleColor,
                  ),
                ),
                const Spacer(),
                if (widget.myBranch.length > 1)
                  TextButton.icon(
                    onPressed: () {
                      _showBranchSelectionDialog(context);
                    },
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('Switch'),
                    style: TextButton.styleFrom(
                      foregroundColor: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),
        
        const SizedBox(height: 8),
        
        // Students list
        Expanded(
          child: StudentsList(
            myBranch: _selectedBranch != null ? [_selectedBranch!] : widget.myBranch,
            selectedYear: selectedYear,
            searchQuery: _searchQuery,
            isDarkMode: isDarkMode,
          ),
        ),
      ],
    );
  }
  
  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        onApply: (String sortBy, bool ascending) {
          // Handle filter application
          Navigator.pop(context);
        },
      ),
    );
  }
  
  void _showBranchSelectionDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Branch'),
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.myBranch.length,
            itemBuilder: (context, index) {
              final branch = widget.myBranch[index];
              return ListTile(
                title: Text(branch),
                leading: Radio<String>(
                  value: branch,
                  groupValue: _selectedBranch,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedBranch = value;
                    });
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedBranch = branch;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }
}

class YearSelector extends ConsumerWidget {
  final String selectedYear;
  
  const YearSelector({
    Key? key,
    required this.selectedYear,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final years = ['First Year', 'Second Year', 'Third Year', 'Fourth Year'];
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: years.length,
        itemBuilder: (context, index) {
          final year = years[index];
          final isSelected = year == selectedYear;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(year),
              labelStyle: TextStyle(
                color: isSelected
                    ? (isDarkMode ? Colors.white : Colors.white)
                    : (isDarkMode ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              selectedColor: isDarkMode ? Colors.deepPurple.shade700 : Colors.deepPurple,
              checkmarkColor: Colors.white,
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onSelected: (bool selected) {
                if (selected) {
                  ref.read(currentYear.notifier).state = year;
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class StudentsList extends StatelessWidget {
  final List<String> myBranch;
  final String selectedYear;
  final String searchQuery;
  final bool isDarkMode;
  
  const StudentsList({
    Key? key,
    required this.myBranch,
    required this.selectedYear,
    required this.searchQuery,
    required this.isDarkMode,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final students = FirebaseFirestore.instance.collection('students');
    
    return StreamBuilder<QuerySnapshot>(
      stream: students
          .where("branch", whereIn: myBranch)
          .where("currentYear", isEqualTo: selectedYear)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState();
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }
        
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }
        
        final studentDocs = snapshot.data!.docs;
        final filteredDocs = searchQuery.isEmpty
            ? studentDocs
            : studentDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final firstName = data['firstName']?.toString().toLowerCase() ?? '';
                final lastName = data['lastName']?.toString().toLowerCase() ?? '';
                final rollNo = data['rollNo']?.toString().toLowerCase() ?? '';
                final query = searchQuery.toLowerCase();
                
                return firstName.contains(query) ||
                      lastName.contains(query) ||
                      rollNo.contains(query);
              }).toList();
        
        if (filteredDocs.isEmpty) {
          return _buildNoMatchState();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            return _buildStudentCard(context, doc);
          },
        );
      },
    );
  }
  
  Widget _buildStudentCard(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final firstName = data['firstName'] ?? '';
    final lastName = data['lastName'] ?? '';
    final fullName = '$firstName $lastName';
    final email = data['email'] ?? '';
    final rollNo = data['rollNo'] ?? '';
    final branch = data['branch'] ?? '';
    final profilePic = data['profilePic'] as String?;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDarkMode ? Colors.grey.shade800 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showStudentDetails(context, data),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Profile Image
              CircleAvatar(
                radius: 24,
                backgroundColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                backgroundImage: profilePic != null && profilePic.isNotEmpty 
                    ? NetworkImage(profilePic) 
                    : null,
                child: profilePic == null || profilePic.isEmpty
                    ? Text(
                        firstName.isNotEmpty ? firstName[0].toUpperCase() : 'S',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.grey.shade700,
                        ),
                      )
                    : null,
              ),
              
              const SizedBox(width: 16),
              
              // Student Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.numbers,
                          size: 14,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rollNo,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.corporate_fare,
                          size: 14,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            branch,
                            style: TextStyle(
                              fontSize: 14,
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
              
              // View Details Button
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                  ),
                  onPressed: () => _showStudentDetails(context, data),
                  tooltip: 'View Details',
                  constraints: const BoxConstraints(
                    minHeight: 36,
                    minWidth: 36,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showStudentDetails(BuildContext context, Map<String, dynamic> studentData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StudentDetailsSheet(
        studentData: studentData,
        isDarkMode: isDarkMode,
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Students Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no students assigned to this branch and year',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading students...',
            style: TextStyle(
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
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
            'Could not load student data',
            style: TextStyle(
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Refresh data
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              foregroundColor: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoMatchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No matches found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Try adjusting your search or filters to find what you\'re looking for',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StudentDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> studentData;
  final bool isDarkMode;
  
  const StudentDetailsSheet({
    Key? key,
    required this.studentData,
    required this.isDarkMode,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final firstName = studentData['firstName'] ?? '';
    final lastName = studentData['lastName'] ?? '';
    final fullName = '$firstName $lastName';
    final email = studentData['email'] ?? '';
    final rollNo = studentData['rollNo'] ?? '';
    final branch = studentData['branch'] ?? '';
    final year = studentData['currentYear'] ?? '';
    final profilePic = studentData['profilePic'] as String?;
    
    // Convert student data to StudentModel if needed
    // final student = StudentModel.fromMap(studentData);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          padding: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Row(
                  children: [
                    Text(
                      'Student Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Student details
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  children: [
                    // Profile section
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                            backgroundImage: profilePic != null && profilePic.isNotEmpty 
                                ? NetworkImage(profilePic) 
                                : null,
                            child: profilePic == null || profilePic.isEmpty
                                ? Text(
                                    firstName.isNotEmpty ? firstName[0].toUpperCase() : 'S',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : Colors.grey.shade700,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            fullName,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              rollNo,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Info Cards
                    InfoCard(
                      title: 'Contact Information',
                      icon: Icons.contact_mail,
                      isDarkMode: isDarkMode,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InfoItem(
                            icon: Icons.email,
                            label: 'Email',
                            value: email,
                            isDarkMode: isDarkMode,
                          ),
                          if (studentData['phone'] != null)
                            InfoItem(
                              icon: Icons.phone,
                              label: 'Phone',
                              value: studentData['phone'],
                              isDarkMode: isDarkMode,
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    InfoCard(
                      title: 'Academic Information',
                      icon: Icons.school,
                      isDarkMode: isDarkMode,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InfoItem(
                            icon: Icons.corporate_fare,
                            label: 'Branch',
                            value: branch,
                            isDarkMode: isDarkMode,
                          ),
                          InfoItem(
                            icon: Icons.calendar_today,
                            label: 'Year',
                            value: year,
                            isDarkMode: isDarkMode,
                          ),
                          if (studentData['semester'] != null)
                            InfoItem(
                              icon: Icons.schedule,
                              label: 'Semester',
                              value: studentData['semester'],
                              isDarkMode: isDarkMode,
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ActionButton(
                          label: 'Email',
                          icon: Icons.email,
                          isDarkMode: isDarkMode,
                          onPressed: () {
                            // Launch email
                          },
                        ),
                        ActionButton(
                          label: 'Attendance',
                          icon: Icons.fact_check,
                          isDarkMode: isDarkMode,
                          onPressed: () {
                            // View attendance
                          },
                        ),
                        ActionButton(
                          label: 'Grades',
                          icon: Icons.grading,
                          isDarkMode: isDarkMode,
                          onPressed: () {
                            // View grades
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool isDarkMode;
  
  const InfoCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.child,
    required this.isDarkMode,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDarkMode;
  
  const InfoItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isDarkMode,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDarkMode;
  
  const ActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.isDarkMode,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon,
                color: isDarkMode ? Colors.white : Colors.black87,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final Function(String, bool) onApply;
  
  const FilterBottomSheet({
    Key? key,
    required this.onApply,
  }) : super(key: key);
  
  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String _sortBy = 'Name';
  bool _ascending = true;
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.75,
      builder: (_, scrollController) {
        return Container(
          padding: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Row(
                  children: [
                    Text(
                      'Filter & Sort',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Filter options
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  children: [
                    Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildSortOption('Name', isDarkMode),
                    _buildSortOption('Roll Number', isDarkMode),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Sort Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        _buildOrderOption('Ascending', true, isDarkMode),
                        const SizedBox(width: 16),
                        _buildOrderOption('Descending', false, isDarkMode),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Apply button
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => widget.onApply(_sortBy, _ascending),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.deepPurple : Colors.black87,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSortOption(String option, bool isDarkMode) {
    final isSelected = _sortBy == option;
    
    return InkWell(
      onTap: () {
        setState(() {
          _sortBy = option;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected 
                  ? (isDarkMode ? Colors.deepPurple.shade300 : Colors.deepPurple) 
                  : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
            const SizedBox(width: 16),
            Text(
              option,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderOption(String label, bool isAscending, bool isDarkMode) {
    final isSelected = _ascending == isAscending;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _ascending = isAscending;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? (isDarkMode ? Colors.deepPurple.withOpacity(0.2) : Colors.deepPurple.withOpacity(0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected 
                  ? (isDarkMode ? Colors.deepPurple.shade300 : Colors.deepPurple) 
                  : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: isSelected 
                    ? (isDarkMode ? Colors.deepPurple.shade300 : Colors.deepPurple) 
                    : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected 
                      ? (isDarkMode ? Colors.deepPurple.shade300 : Colors.deepPurple) 
                      : (isDarkMode ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
