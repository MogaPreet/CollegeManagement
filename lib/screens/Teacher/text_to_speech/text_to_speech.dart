import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import 'package:speech_to_text/speech_to_text.dart';

class LectureRecorderScreen extends StatefulWidget {
  const LectureRecorderScreen({Key? key}) : super(key: key);

  @override
  State<LectureRecorderScreen> createState() => _LectureRecorderScreenState();
}

class _LectureRecorderScreenState extends State<LectureRecorderScreen> {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _transcription = '';

  Future<void> _initSpeech() async {
    await _speech.initialize();
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _startListening() async {
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _transcription = result.recognizedWords;
        });
      },
      listenMode: ListenMode.dictation,
    );
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryPage(transcription: _transcription),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecture Recorder'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _transcription.isEmpty
                      ? 'Start speaking to see transcription here...'
                      : _transcription,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.mic),
                  label: const Text('Start'),
                  onPressed: !_isListening ? _startListening : null,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.stars_outlined),
                  label: const Text('Summerize'),
                  onPressed: _isListening ? _stopListening : null,
                ),
              ],
            ),
          ],
        ),
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
                child: ListTile(
                  title: Container(
                    height: 10,
                    color: Colors.grey,
                  ),
                  subtitle: Container(
                    height: 10,
                    margin: EdgeInsets.only(top: 5),
                    color: Colors.grey,
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
