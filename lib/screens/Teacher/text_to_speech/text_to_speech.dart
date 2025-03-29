import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_svg/flutter_svg.dart';


class LectureRecorderScreen extends StatefulWidget {
  const LectureRecorderScreen({Key? key}) : super(key: key);

  @override
  State<LectureRecorderScreen> createState() => _LectureRecorderScreenState();
}

class _LectureRecorderScreenState extends State<LectureRecorderScreen> with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _transcription = '';
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  int _speechDuration = 0;
  bool _isInitialized = false;
  Timer? _timer;
  
  // For display purposes
  int _wordCount = 0;
  double _confidenceLevel = 0.0;
  String _language = 'en-US';
  bool _showIntro = true;
  
  // For immersive UI
  final PageController _pageController = PageController();
  final List<Color> _waveColors = [
    Colors.deepPurple,
    Colors.blue,
    Colors.pinkAccent,
    Colors.teal,
    Colors.amber,
  ];
  int _colorIndex = 0;
  bool _showTips = false;
  
  // For waveform visualization
  final List<double> _waveformData = List.filled(60, 0);
  Timer? _waveformTimer;

  Future<void> _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: true,
      );
      
      if (available) {
        setState(() {
          _isInitialized = true;
          _showIntro = true;
        });
        
        // Hide intro after 3 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showIntro = false;
            });
          }
        });
      } else {
        _showErrorDialog("Speech recognition is not available on this device.");
      }
    } catch (e) {
      _showErrorDialog("Error initializing speech recognition: $e");
    }
  }
  
  void _onSpeechStatus(String status) {
    if (status == 'notListening' && _isListening) {
      setState(() {
        _isListening = false;
      });
      _stopTimer();
      _stopWaveformSimulation();
    }
  }
  
  void _onSpeechError(SpeechRecognitionError error) {
    print("Speech error: ${error.errorMsg}");
    if (mounted) {
      setState(() {
        _isListening = false;
      });
      _stopTimer();
      _stopWaveformSimulation();
      
      // Show error only for non-timeout errors
      if (error.errorMsg != "error_speech_timeout") {
        _showCustomSnackBar(
          message: 'Speech recognition error: ${error.errorMsg}',
          isError: true,
        );
      }
    }
  }
  
  void _showCustomSnackBar({required String message, bool isError = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: isError 
          ? Colors.red.shade700 
          : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
    
    _animationController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1500),
    );
    
    _pulseAnimation = Tween(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.repeat(reverse: true);
    
    // Cycle through wave colors
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _isListening) {
        setState(() {
          _colorIndex = (_colorIndex + 1) % _waveColors.length;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _stopTimer();
    _timer?.cancel();
    _pageController.dispose();
    _stopWaveformSimulation();
    _waveformTimer?.cancel();
    super.dispose();
  }
  
  void _startTimer() {
    _speechDuration = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _speechDuration++;
      });
    });
  }
  
  void _stopTimer() {
    _timer?.cancel();
  }
  
  void _startWaveformSimulation() {
    final random = DateTime.now().millisecondsSinceEpoch;
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && _isListening) {
        setState(() {
          for (int i = 0; i < _waveformData.length; i++) {
            // Create a somewhat realistic waveform pattern based on syllable patterns
            final double baseAmplitude = 0.3;
            final double randomFactor = (DateTime.now().millisecondsSinceEpoch + i * random) % 100 / 100;
            final double syllablePattern = (i % 4 == 0) ? 0.7 : 0.3;
            
            _waveformData[i] = baseAmplitude + randomFactor * syllablePattern;
          }
        });
      }
    });
  }
  
  void _stopWaveformSimulation() {
    _waveformTimer?.cancel();
    if (mounted) {
      setState(() {
        _waveformData.fillRange(0, _waveformData.length, 0.1);
      });
    }
  }

  void _startListening() async {
    try {
      if (!_isInitialized) {
        await _initSpeech();
      }
      
      if (_speech.isAvailable) {
        setState(() {
          _isListening = true;
        });
        
        _startTimer();
        _startWaveformSimulation();
        
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _transcription = result.recognizedWords;
              _confidenceLevel = result.confidence;
              _wordCount = _transcription.split(' ').length;
            });
          },
          listenMode: ListenMode.dictation,
          pauseFor: const Duration(seconds: 3),
          cancelOnError: false,
          partialResults: true,
        );
      } else {
        _showErrorDialog("Speech recognition is not available on this device.");
      }
    } catch (e) {
      _showErrorDialog("Error starting speech recognition: $e");
      setState(() {
        _isListening = false;
      });
    }
  }

  void _stopListening() async {
    try {
      await _speech.stop();
      _stopTimer();
      _stopWaveformSimulation();
      setState(() {
        _isListening = false;
      });
      
      if (_transcription.isNotEmpty) {
        _showConfirmationDialog();
      } else {
        _showCustomSnackBar(
          message: 'No speech was detected. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      print("Error stopping speech recognition: $e");
      setState(() {
        _isListening = false;
      });
    }
  }
  
  void _showErrorDialog(String message) {
    if (!mounted) return;
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400),
            const SizedBox(width: 12),
            const Text(
              'Error',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
            style: TextButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.deepPurple.shade300 : Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showConfirmationDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? Colors.deepPurple.withOpacity(0.2) 
                    : Colors.deepPurple.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: isDarkMode ? Colors.deepPurple.shade300 : Colors.deepPurple,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Lecture Recorded!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your lecture has been recorded. Would you like to generate a summary?',
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2A2A3E) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined, 
                        size: 18,
                        color: isDarkMode ? Colors.deepPurple.shade300 : Colors.deepPurple,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Lecture Statistics',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildStatRow(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: _formatDuration(_speechDuration),
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    icon: Icons.text_fields,
                    label: 'Word Count',
                    value: '$_wordCount words',
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    icon: Icons.calculate_outlined,
                    label: 'Speaking Rate',
                    value: _speechDuration > 0 
                        ? '${(_wordCount / (_speechDuration / 60)).round()} words/min' 
                        : 'N/A',
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? Colors.blue.shade900.withOpacity(0.2) 
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode 
                      ? Colors.blue.shade800.withOpacity(0.3) 
                      : Colors.blue.shade100,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade800,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Summarizing can help create concise notes for your students',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.blue.shade100 : Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSaveOptionsSheet();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
              side: BorderSide(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            child: const Text(
              'SAVE AS TEXT',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => SummaryPage(transcription: _transcription),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeOutQuint;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.deepPurple.shade400 : Colors.deepPurple,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            child: const Text(
              'GENERATE SUMMARY',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showSaveOptionsSheet() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.save_alt,
                    size: 24,
                    color: isDarkMode ? Colors.deepPurple.shade300 : Colors.deepPurple,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Save Options',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 4),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Choose how to save your lecture',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildSaveOption(
                    title: 'Copy to Clipboard',
                    subtitle: 'Copy the text to paste anywhere',
                    icon: Icons.content_copy,
                    iconColor: Colors.blue,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.pop(context);
                      Clipboard.setData(ClipboardData(text: _transcription));
                      _showCustomSnackBar(message: 'Copied to clipboard');
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildSaveOption(
                    title: 'Share',
                    subtitle: 'Share via messaging or email',
                    icon: Icons.share,
                    iconColor: Colors.green,
                    isDarkMode: isDarkMode,
                    onTap: () async {
                      Navigator.pop(context);
                      final result = await Share.share(
                        _transcription,
                        subject: 'Lecture Transcription',
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildSaveOption(
                    title: 'Save as File',
                    subtitle: 'Save to a text file on your device',
                    icon: Icons.file_present,
                    iconColor: Colors.orange,
                    isDarkMode: isDarkMode,
                    onTap: () async {
                      Navigator.pop(context);
                      await _saveToFile();
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildSaveOption(
                    title: 'Clear & Start New',
                    subtitle: 'Clear current text and start a new recording',
                    icon: Icons.refresh,
                    iconColor: Colors.red,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _transcription = '';
                      });
                      _showCustomSnackBar(message: 'Cleared. Ready for a new recording.');
                    },
                  ),
                ],
              ),
            ),
            
            // Close button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode 
                        ? Colors.grey.shade800 
                        : Colors.grey.shade200,
                    foregroundColor: isDarkMode 
                        ? Colors.white 
                        : Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CLOSE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _saveToFile() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        _showCustomSnackBar(
          message: 'Storage access error',
          isError: true,
        );
        return;
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'lecture_$timestamp.txt';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(_transcription);
      
      _showCustomSnackBar(
        message: 'Saved to ${file.path}',
      );
    } catch (e) {
      _showCustomSnackBar(
        message: 'Failed to save file: $e',
        isError: true,
      );
    }
  }
  
  Widget _buildStatRow({
    required IconData icon, 
    required String label, 
    required String value,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Icon(
          icon, 
          size: 14,
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 13,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSaveOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900.withOpacity(0.5) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(isDarkMode ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _isListening ? 'Recording Lecture...' : 'Voice Lecture Studio',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        actions: [
          IconButton(
            icon: Icon(_showTips ? Icons.lightbulb : Icons.lightbulb_outline),
            onPressed: () {
              setState(() {
                _showTips = !_showTips;
              });
            },
            tooltip: _showTips ? 'Hide Tips' : 'Show Tips',
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode 
                  ? [
                      const Color(0xFF1A1A2E),
                      const Color(0xFF16213E),
                      const Color(0xFF0F3460),
                    ]
                  : [
                      const Color(0xFFF5F7FA),
                      const Color(0xFFE4EDF5),
                      const Color(0xFFD5E5F2),
                    ],
              ),
            ),
          ),
          
          // Background patterns
          Positioned.fill(
            child: Opacity(
              opacity: isDarkMode ? 0.06 : 0.08,
              child: Image.network(
                isDarkMode
                  ? 'https://img.freepik.com/free-photo/abstract-gradient-neon-lights_23-2149279138.jpg?semt=ais_hybrid' // Dark pattern
                  : 'https://img.freepik.com/free-photo/abstract-gradient-neon-lights_23-2149279138.jpg?semt=ais_hybrid', // Light pattern
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Tips section (collapsible)
                if (_showTips)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                        ? Colors.indigo.withOpacity(0.2)
                        : Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode
                          ? Colors.indigo.shade900.withOpacity(0.3)
                          : Colors.indigo.shade100,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.tips_and_updates,
                              color: isDarkMode
                                ? Colors.indigo.shade300
                                : Colors.indigo.shade700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tips For Best Results',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // _buildTip(
                        //   'Speak clearly and at a moderate pace',
                        //   isDarkMode,
                        // ),
                        // _buildTip(
                        //   'Minimize background noise',
                        //   isDarkMode,
                        // ),
                        // _buildTip(
                        //   'Hold your device 6-12 inches away',
                        //   isDarkMode,
                        // ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 8),
                
                // Status area with waveform visualization
                if (!_showIntro)
                  Container(
                    height: 120,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode 
                          ? Colors.black.withOpacity(0.3) 
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isListening
                          ? _waveColors[_colorIndex].withOpacity(isDarkMode ? 0.5 : 0.3)
                          : isDarkMode 
                              ? Colors.grey.shade800 
                              : Colors.grey.shade300,
                        width: _isListening ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status text
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _isListening
                                    ? isDarkMode
                                        ? _waveColors[_colorIndex].withOpacity(0.2)
                                        : _waveColors[_colorIndex].withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isListening ? Icons.mic : Icons.mic_off,
                                color: _isListening
                                    ? _waveColors[_colorIndex]
                                    : isDarkMode 
                                        ? Colors.grey.shade400 
                                        : Colors.grey.shade700,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isListening ? 'Listening...' : 'Ready to listen',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  _isListening
                                      ? 'Recording: ${_formatDuration(_speechDuration)}'
                                      : 'Tap the microphone to start',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode 
                                        ? Colors.grey.shade400 
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (_isListening)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    _buildPulsingDot(),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'LIVE',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        
                        // Waveform visualization
                        // if (_isListening)
                        //   Expanded(
                        //     child: AudioWaveforms(
                        //       waveData: _waveformData,
                        //       waveColor: _waveColors[_colorIndex],
                        //       backgroundColor: Colors.transparent,
                        //       borderColor: Colors.transparent,
                        //       borderWidth: 0,
                        //       waveThickness: 2,
                        //       waveGap: 2,
                        //       waveHeightFactor: 0.6,
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                
                // Introduction animation
                if (_showIntro)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/lecture.json',
                            width: screenSize.width * 0.6,
                            height: screenSize.width * 0.6,
                            fit: BoxFit.contain,

                            
                            animate: true,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Voice Lecture Assistant',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: screenSize.width * 0.8,
                            child: Text(
                              'Speak naturally and your lecture will be transcribed and summarized automatically.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode 
                                    ? Colors.grey.shade300 
                                    : Colors.grey.shade800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showIntro = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode ? const Color(0xFFAD8DF9) : Colors.deepPurple,
                              foregroundColor: isDarkMode ? Colors.black87 : Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 3,
                              shadowColor: isDarkMode ? Colors.purple.shade800.withOpacity(0.3) : Colors.purple.withOpacity(0.3),
                            ),
                            child: Text(
                              'Get Started',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                // Transcription area
                if (!_showIntro)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? Colors.black.withOpacity(0.3) 
                            : Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode 
                              ? Colors.grey.shade800 
                              : Colors.grey.shade300,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Transcription',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              if (_transcription.isNotEmpty)
                                Row(
                                  children: [
                                    _buildIconButton(
                                      icon: Icons.copy,
                                      tooltip: 'Copy Text',
                                      onPressed: () {
                                        final scaffold = ScaffoldMessenger.of(context);
                                        Clipboard.setData(ClipboardData(text: _transcription));
                                        scaffold.showSnackBar(
                                          SnackBar(
                                            content: const Text('Transcription copied to clipboard'),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    _buildIconButton(
                                      icon: Icons.delete_outline,
                                      tooltip: 'Clear Text',
                                      onPressed: () {
                                        setState(() {
                                          _transcription = '';
                                        });
                                      },
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(
                            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                            height: 1,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: _transcription.isEmpty
                                  ? _buildEmptyState(isDarkMode)
                                  : _buildTranscriptionText(isDarkMode),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isListening ? _stopListening : _startListening,
        backgroundColor: _isListening ? Colors.red : Colors.green,
        child: Icon(_isListening ? Icons.stop : Icons.mic),
      ),
    );
  }
  
  Widget _buildPulsingDot() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic_off,
            size: 48,
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No transcription available',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTranscriptionText(bool isDarkMode) {
    return MarkdownBody(
      data: _transcription,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          fontSize: 16,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
  
  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade300
          : Colors.grey.shade700,
    );
  }
  
  void _showHelpDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Help',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To start recording your lecture, tap the microphone button. Speak naturally and your lecture will be transcribed in real-time.',
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'When you are done, tap the stop button. You can then generate a summary of your lecture.',
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class SummaryPage extends StatefulWidget {
  final String transcription;

  const SummaryPage({Key? key, required this.transcription}) : super(key: key);

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  late Future<String> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _generateSummary(widget.transcription);
  }

  Future<String> _generateSummary(String text) async {
    final apiKey = 'AIzaSyCd3mvMdoEx7_1KJ5AcCLyNQXRN4u9aWJc';
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text':
                    'Summarize the following lecture: $text use bullet points for better explanation'
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Failed to summarize text');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecture Summary'),
        centerTitle: true,
      ),
      body: FutureBuilder<String>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[700]!,
                child: const ListTile(
                  title: SizedBox(
                    height: 10,
                    
                  ),
                  subtitle: SizedBox(
                    height: 10,
                
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  snapshot.data ?? 'No summary available.',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
