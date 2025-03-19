import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
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
          if (hasBudget)
            Positioned(
              right: 16,
              bottom: 16,
              child: InkWell(
                onTap: () => _openBudgetDiscussion(context,event),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.forum, size: 16, color: Colors.indigo),
                      SizedBox(width: 4),
                      Text(
                        'Budget Chat',
                        style: TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
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

void _openBudgetDiscussion(BuildContext context,Event event) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => BudgetDiscussionPage(
        eventId: event.id,
        eventTitle: event.title,
      ),
    ),
  );
}

// Extension to check if two dates are the same
extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}



// Add this class at the end of the file
class BudgetDiscussionPage extends ConsumerStatefulWidget {
  final String eventId;
  final String eventTitle;

  const BudgetDiscussionPage({
    Key? key,
    required this.eventId,
    required this.eventTitle,
  }) : super(key: key);

  @override
  ConsumerState<BudgetDiscussionPage> createState() => _BudgetDiscussionPageState();
}

class _BudgetDiscussionPageState extends ConsumerState<BudgetDiscussionPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAiThinking = false;
  bool _isFirstLoad = true;
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageStream = ref.watch(
      discussionMessagesProvider(widget.eventId)
    );

    // For first load with messages, scroll to bottom
    if (_isFirstLoad && messageStream.maybeWhen(
      data: (messages) => messages.isNotEmpty,
      orElse: () => false,
    )) {
      _isFirstLoad = false;
      _scrollToBottom();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Discussion: ${widget.eventTitle}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About Budget Discussion',
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messageStream.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.forum_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start the conversation about expenses',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }
                
                _scrollToBottom();
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message.userId == FirebaseAuth.instance.currentUser?.uid;
                    final isAI = message.isAI;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: isCurrentUser || isAI
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar for other users
                          if (!isCurrentUser && !isAI)
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: _getAvatarColor(message.userName),
                              child: Text(
                                _getInitials(message.userName),
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                          const SizedBox(width: 8),
                          
                          // Message bubble
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isAI 
                                    ? Colors.indigo.withOpacity(0.15)
                                    : (isCurrentUser 
                                        ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                                        : Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: isCurrentUser || isAI 
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  // Sender name
                                  if (!isCurrentUser || isAI)
                                    Text(
                                      isAI ? 'Gemini AI' : message.userName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: isAI 
                                            ? Colors.indigo
                                            : (isCurrentUser 
                                                ? Colors.white70
                                                : Colors.black54),
                                      ),
                                    ),
                                  
                                  // Message content
                                  Text(
                                    message.text,
                                    style: TextStyle(
                                      color: isCurrentUser && !isAI ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 4),
                                  
                                  // Timestamp
                                  Text(
                                    DateFormat('h:mm a').format(message.timestamp),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isCurrentUser && !isAI
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // Avatar for current user
                          if (isCurrentUser && !isAI)
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(
                                _getInitials(message.userName),
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                          // Gemini avatar
                          if (isAI)
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.indigo.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/gemini_icon.png',
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.smart_toy,
                                    color: Colors.indigo,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Error loading messages: $error'),
              ),
            ),
          ),
          
          // AI processing indicator
          if (_isAiThinking)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: Colors.indigo.withOpacity(0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.indigo.shade400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Gemini is thinking...',
                    style: TextStyle(
                      color: Colors.indigo.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          
          // Message input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.indigo,
                    child: IconButton(
                      tooltip: 'Ask Gemini',
                      icon: const Icon(Icons.smart_toy, color: Colors.white),
                      onPressed: _askGemini,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to send messages')),
      );
      return;
    }
    
    _messageController.clear();
    
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('discussions')
          .add({
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'isAI': false,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }
  
  void _askGemini() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Image.asset(
              'assets/gemini_icon.png',
              width: 24,
              height: 24,
              errorBuilder: (_, __, ___) => const Icon(Icons.smart_toy, color: Colors.indigo),
            ),
            const SizedBox(width: 8),
            const Text('Ask Gemini about Budget'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose a question or type your own:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildGeminiQuestionButton(context, 'How can we stay within budget?'),
            _buildGeminiQuestionButton(context, 'Analyze our current spending'),
            _buildGeminiQuestionButton(context, 'Suggest ways to reduce costs'),
            _buildGeminiQuestionButton(context, 'Help allocate budget to categories'),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Or type your budget question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = _messageController.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context);
                _sendUserMessageAndGetGeminiResponse(text);
              }
            },
            child: const Text('Ask'),
          ),
        ],
      ),
    );
  }

  Widget _buildGeminiQuestionButton(BuildContext context, String question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          _sendUserMessageAndGetGeminiResponse(question);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.indigo.withOpacity(0.3)),
          ),
          child: Text(question),
        ),
      ),
    );
  }
  
  Future<void> _sendUserMessageAndGetGeminiResponse(String question) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    // First add the user's question to the chat
    await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('discussions')
        .add({
      'text': question,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': user.uid,
      'userName': user.displayName ?? 'Anonymous',
      'isAI': false,
    });
    
    setState(() {
      _isAiThinking = true;
    });
    
    try {
      // Get event data for context
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();
      
      final expensesSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('expenses')
          .get();
      
      // Calculate useful aggregations
      double totalExpenses = 0;
      Map<String, double> categoryTotals = {};
      
      for (final doc in expensesSnapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        totalExpenses += amount;
        
        final category = data['category'] as String? ?? 'Other';
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      }
      
      // Get budget info if available
      double? budgetAmount;
      final eventData = eventDoc.data();
      if (eventData != null && eventData.containsKey('estimatedBudget')) {
        final budgetText = eventData['estimatedBudget'].toString();
        RegExp totalRegex = RegExp(r'Total Estimated Budget:.*?₹(\d+[,\d]*)');
        final match = totalRegex.firstMatch(budgetText);
        
        if (match != null && match.groupCount >= 1) {
          final totalString = match.group(1)?.replaceAll(',', '');
          budgetAmount = double.tryParse(totalString ?? '');
        }
      }
      
      // Format expense data for Gemini
      final expenseSummary = categoryTotals.entries.map((e) => 
        "- ${e.key}: ₹${e.value.toStringAsFixed(2)}"
      ).join("\n");
      
      final budgetStatus = budgetAmount != null 
          ? "Budget: ₹${budgetAmount.toStringAsFixed(2)}, Spent: ₹${totalExpenses.toStringAsFixed(2)}, Remaining: ₹${(budgetAmount - totalExpenses).toStringAsFixed(2)}"
          : "Total expenses: ₹${totalExpenses.toStringAsFixed(2)} (no formal budget set)";
      
      // Create the prompt for Gemini
      final prompt = """
As a financial advisor helping with a college event, answer this question about budget management:
"$question"

Context about the event "${widget.eventTitle}":
$budgetStatus

Expense breakdown:
$expenseSummary

Provide practical advice that's specific to this event's financial situation. Be concise yet helpful, and focus on actionable suggestions.
""";

      // Send to Gemini API
      final geminiResponse = await ref.read(geminiProvider).generateContent([Content.text(prompt)]);
      final aiMessage = geminiResponse.text;

      // Post the AI response to the discussion thread
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('discussions')
          .add({
        'text': aiMessage,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': 'gemini-ai',
        'userName': 'Gemini AI',
        'isAI': true,
      });
    } catch (e) {
      // Only show error if still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gemini response failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAiThinking = false;
        });
      }
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('About Budget Discussion'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'This is where your team can discuss event expenses and get AI assistance for budget management.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('• Chat with team members about budget decisions'),
            Text('• Ask Gemini for AI-powered budget advice'),
            Text('• Discuss expense priorities and allocations'),
            Text('• Get real-time spending analysis'),
            SizedBox(height: 12),
            Text(
              'Tip: Click the Gemini icon to get AI help with budget planning, cost reduction strategies, and financial advice.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
    } else if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }
  
  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.red,
    ];
    
    final index = name.isEmpty ? 0 : name.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}

// Message model to better handle chat data
class DiscussionMessage {
  final String id;
  final String text;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final bool isAI;
  
  DiscussionMessage({
    required this.id,
    required this.text,
    required this.userId,
    required this.userName,
    required this.timestamp,
    this.isAI = false,
  });
  
  factory DiscussionMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiscussionMessage(
      id: doc.id,
      text: data['text'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      timestamp: data['timestamp'] != null 
          ? (data['timestamp'] as Timestamp).toDate() 
          : DateTime.now(),
      isAI: data['isAI'] ?? false,
    );
  }
}

// Provider for discussion messages
final discussionMessagesProvider = StreamProvider.family<List<DiscussionMessage>, String>(
  (ref, eventId) {
    return FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('discussions')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DiscussionMessage.fromFirestore(doc))
            .toList());
  },
);

// Gemini provider (assuming you already have this set up from previous code)
final geminiProvider = Provider<GenerativeModel>((ref) {
  final apiKey = 'AIzaSyCd3mvMdoEx7_1KJ5AcCLyNQXRN4u9aWJc';
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
  );
  return model;
});