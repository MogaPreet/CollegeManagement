import 'package:cms/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';

class StudentCard extends StatefulWidget {
  final StudentModel student;
  const StudentCard({super.key, required this.student});

  @override
  State<StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Calculate semester from year
    String? semester;
    if (widget.student.currentYear != null) {
      try {
        final year = int.parse(widget.student.currentYear!);
        semester = ((year - 1) * 2 + 1).toString();
      } catch (e) {
        semester = null;
      }
    }
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            elevation: 8,
            shadowColor: isDark 
                ? Colors.indigo.withOpacity(0.4) 
                : Colors.indigo.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: isDark ? Colors.indigo.shade700 : Colors.indigo.shade200,
                width: 1,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark 
                    ? [Colors.indigo.shade900, Colors.deepPurple.shade900]
                    : [Colors.indigo.shade100, Colors.deepPurple.shade100],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Section
                  _buildProfileHeader(isDark),
                  
                  // Information Section
                  _buildInformationSection(isDark, semester),
                  
                  // Bottom action buttons
                  _buildBottomActions(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader(bool isDark) {
    final profileImage = 
        "https://ui-avatars.com/api/?name=${widget.student.firstName}+${widget.student.lastName ?? ''}&background=random";
    
    return Container(
      height: 130,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [Colors.indigo.shade800, Colors.deepPurple.shade800]
            : [Colors.indigo.shade400, Colors.deepPurple.shade400],
        ),
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            right: -15,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -25,
            bottom: -25,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Profile image
                Hero(
                  tag: 'profile-${widget.student.firstName ?? "student"}',
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(45),
                      child: CachedNetworkImage(
                        imageUrl: profileImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.person,
                          size: 40,
                          color: isDark ? Colors.white70 : Colors.indigo.shade300,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Name and badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${widget.student.firstName ?? ""} ${widget.student.lastName ?? ""}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      if (widget.student.rollNo != null)
                        Text(
                          widget.student.rollNo!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        
                      const SizedBox(height: 8),
                      
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.shade300,
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          "Active Student",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationSection(bool isDark, String? semester) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Main info grid
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  isDark,
                  icon: Icons.school_rounded,
                  title: widget.student.branch ?? "Branch",
                  subtitle: "Department",
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  isDark,
                  icon: Icons.calendar_today_rounded,
                  title: "${widget.student.currentYear ?? "-"} Year",
                  subtitle: semester != null ? "$semester Semester" : "Current",
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Divider
          Divider(
            color: isDark ? Colors.white12 : Colors.black12,
            thickness: 1,
          ),
          
          const SizedBox(height: 12),
          
          // Contact Information
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                size: 16,
                color: isDark ? Colors.white70 : Colors.indigo.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.student.email ?? "No email provided",
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          if (widget.student.uid != null)
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 16,
                  color: isDark ? Colors.white70 : Colors.indigo.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.student.uid!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.indigo.withOpacity(0.2) 
                : Colors.indigo.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildBottomActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              // View full profile
            },
            icon: Icon(
              Icons.person_outline_rounded,
              size: 16,
              color: isDark ? Colors.white : Colors.indigo,
            ),
            label: Text(
              "View Profile",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.indigo,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isDark ? Colors.white30 : Colors.indigo.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          FilledButton.icon(
            onPressed: () {
              // Edit profile
            },
            icon: const Icon(
              Icons.edit_outlined,
              size: 16,
            ),
            label: const Text("Edit"),
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? Colors.indigo.shade700 : Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}