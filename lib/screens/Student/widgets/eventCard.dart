import 'package:cms/models/event.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
    // Get appropriate event image based on location type
    String eventImage = getEventImageUrl(event);
    
    // Format the date safely
    String dateText = formatEventDate(event.startDate);
    
    // Check if the event has a budget
    bool hasBudget = false;
    try {
      hasBudget = event.estimatedBudget != null && event.estimatedBudget!.isNotEmpty;
    } catch (e) {
      // Handle case where estimatedBudget is not defined in the model
      hasBudget = false;
    }
    
    return Card(
      elevation: 4,
      color: Colors.black,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: size.height * 0.25,
        child: Stack(
          children: [
            // Background Image with Gradient
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Colors.black,
                    ],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Image.network(
                  eventImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: double.infinity,
                          height: size.height * 0.25,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: size.height * 0.25,
                      color: Colors.grey.shade800,
                      child: const Icon(
                        Icons.event,
                        size: 50,
                        color: Colors.white54,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Content overlay
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with budget indicator if available
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasBudget)
                        Tooltip(
                          message: 'Budget plan available',
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.greenAccent[400],
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Date and time row
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey[200],
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        dateText,
                        style: TextStyle(
                          color: Colors.grey[200],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Icon(
                        Icons.access_time,
                        color: Colors.grey[200],
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        event.time,
                        style: TextStyle(
                          color: Colors.grey[200],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Location row with type indicator
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(
                            color: Colors.grey[400],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Location type chip
                      if (_hasLocationType(event))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getLocationTypeColor(event),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getLocationType(event),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  // Event description
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Footer row with attendees count and duration if available
                  _buildFooterRow(event),
                ],
              ),
            ),
            
            // Multi-day indicator badge
            if (_isMultidayEvent(event))
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_getEventDuration(event)} days',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to get appropriate event image based on event type
  String getEventImageUrl(Event event) {
    // Try to determine the event type from the description or location
    String eventType = event.description.toLowerCase();
    
    // Check if the event has a location type
    String? locationType;
    try {
      locationType = event.locationType?.toLowerCase();
    } catch (e) {
      // Handle case where locationType is not defined in the model
      locationType = null;
    }
    
    if (locationType == 'outside college' || eventType.contains('excursion') || eventType.contains('trip')) {
      return "https://images.unsplash.com/photo-1507608616759-54f48f0af0ee?q=80&w=1740&auto=format&fit=crop";
    } else if (eventType.contains('workshop') || eventType.contains('seminar')) {
      return "https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=1740&auto=format&fit=crop";
    } else if (eventType.contains('cultural') || eventType.contains('fest') || eventType.contains('celebration')) {
      return "https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?q=80&w=1740&auto=format&fit=crop";
    } else if (eventType.contains('tech') || eventType.contains('hackathon') || eventType.contains('competition')) {
      return "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&w=1740&auto=format&fit=crop";
    } else {
      // Default image
      return "https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";
    }
  }
  
  // Helper method to format the date safely
  String formatEventDate(DateTime? date) {
    if (date == null) {
      return "Date TBD";
    }
    
    try {
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "Date error";
    }
  }
  
  // Helper method to check if an event has a location type
  bool _hasLocationType(Event event) {
    try {
      return event.locationType != null && event.locationType!.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // Helper method to get the location type text
  String _getLocationType(Event event) {
    try {
      if (event.locationType == 'In-College') {
        return 'In-College';
      } else if (event.locationType == 'Outside College') {
        return 'Outside';
      } else {
        return event.locationType ?? '';
      }
    } catch (e) {
      return '';
    }
  }
  
  // Helper method to get color based on location type
  Color _getLocationTypeColor(Event event) {
    try {
      if (event.locationType == 'In-College') {
        return Colors.green.withOpacity(0.8);
      } else if (event.locationType == 'Outside College') {
        return Colors.purple.withOpacity(0.8);
      } else {
        return Colors.grey.withOpacity(0.8);
      }
    } catch (e) {
      return Colors.grey.withOpacity(0.8);
    }
  }
  
  // Helper method to check if event is multi-day
  bool _isMultidayEvent(Event event) {
    try {
      if (event.totalDays != null && event.totalDays! > 1) {
        return true;
      }
      
      if (event.startDate != null && event.endDate != null) {
        return !event.startDate!.isSameDate(event.endDate!);
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Helper method to get the event duration in days
  int _getEventDuration(Event event) {
    try {
      if (event.totalDays != null) {
        return event.totalDays!;
      }
      
      if (event.startDate != null && event.endDate != null) {
        return event.endDate!.difference(event.startDate!).inDays + 1;
      }
      
      return 1;
    } catch (e) {
      return 1;
    }
  }
  
  // Build the footer row with additional information
  Widget _buildFooterRow(Event event) {
    Widget? attendeesWidget;
    try {
      if (event.estimatedAttendees != null) {
        attendeesWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              color: Colors.grey[400],
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              '${event.estimatedAttendees} attendees',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        );
      }
    } catch (e) {
      attendeesWidget = null;
    }
    
    Widget? feeWidget;
    try {
      if (event.fee != null && event.fee! > 0) {
        feeWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.currency_rupee,
              color: Colors.amber[400],
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              '${event.fee}',
              style: TextStyle(
                color: Colors.amber[400],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }
    } catch (e) {
      feeWidget = null;
    }
    
    if (attendeesWidget != null || feeWidget != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (attendeesWidget != null) attendeesWidget,
          if (feeWidget != null) feeWidget,
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

// Extension to check if two dates are the same
extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}