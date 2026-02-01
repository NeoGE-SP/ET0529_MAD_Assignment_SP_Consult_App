/* import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


Future<String> getOpenRouterResponse(String userInput) async {
  const endpoint = 'https://openrouter.ai/api/v1/chat/completions';

  final headers = {
    'Authorization': 'Bearer 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',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    'model': 'gpt-3.5-turbo',
    'messages': [
      {
        'role': 'system',
        'content': 'You are a helpful assistant that summarizes text.'
      },
      {
        'role': 'user',
        'content': userInput
      }
    ],
    'max_tokens': 200,
    'temperature': 0.7,
  });

  final response = await http.post(
    Uri.parse(endpoint),
    headers: headers,
    body: body,
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  } else {
    throw Exception('Failed to get response: ${response.body}');
  }
}

class NoteSummarizer extends StatefulWidget {
  const NoteSummarizer({super.key});

  @override
  NoteSummarizerState createState() => NoteSummarizerState();
}

class NoteSummarizerState extends State<NoteSummarizer> {
  final TextEditingController _noteController = TextEditingController();
  String _summary = "";
  bool _loading = false;

  Future<void> summarizeNote() async {
    final userNote = _noteController.text.trim();
    if (userNote.isEmpty) return;

    setState(() {
      _loading = true;
      _summary = "";
    });

    try {
      final result = await getOpenRouterResponse(userNote);
      setState(() {
        _summary = result;
      });
    } catch (e) {
      setState(() {
        _summary = "Error: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Note Summarizer")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _noteController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Type your note here...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : summarizeNote,
              child: _loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text("Summarize"),
            ),
            SizedBox(height: 16),
            if (_summary.isNotEmpty)
              Container(
                padding: EdgeInsets.all(12),
                color: Colors.grey[200],
                child: Text(_summary),
              ),
          ],
        ),
      ),
    );
  }
} */

import 'dart:convert';
import 'dart:async'; // Required for FutureOr if used elsewhere
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(home: NoteSummarizer()));
}

Future<String> getOpenRouterResponse(String userInput) async {
  const endpoint = 'https://openrouter.ai/api/v1/chat/completions';

  final headers = {
    'Authorization': 'Bearer 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',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    'model': 'gpt-3.5-turbo',
    'messages': [
      {
        'role': 'system',
        'content': 'You are a helpful assistant that summarizes the important parts of the text.'
      },
      {
        'role': 'user',
        'content': userInput
      }
    ],
    'max_tokens': 200,
    'temperature': 0.7,
  });

  final response = await http.post(
    Uri.parse(endpoint),
    headers: headers,
    body: body,
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // FIX: Accessing ['message']['content'] instead of ['text']
    // Also using '??' to ensure we never return a Null type
    return data['choices'][0]['message']['content'] ?? "No summary generated.";
  } else {
    throw Exception('Failed to get response: ${response.body}');
  }
}

class NoteSummarizer extends StatefulWidget {
  const NoteSummarizer({super.key});

  @override
  NoteSummarizerState createState() => NoteSummarizerState();
}

class NoteSummarizerState extends State<NoteSummarizer> {
  final TextEditingController _noteController = TextEditingController();
  String _summary = "";
  bool _loading = false;

  Future<void> summarizeNote() async {
    final userNote = _noteController.text.trim();
    if (userNote.isEmpty) return;

    setState(() {
      _loading = true;
      _summary = "";
    });

    try {
      final result = await getOpenRouterResponse(userNote);
      setState(() {
        _summary = result;
      });
    } catch (e) {
      setState(() {
        _summary = "Error: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Note Summarizer")),
      // FIX: Added SingleChildScrollView to prevent bottom overflow
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _noteController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Type your note here...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : summarizeNote,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.blue, 
                          strokeWidth: 2
                        ),
                      )
                    : const Text("Summarize"),
              ),
              const SizedBox(height: 16),
              if (_summary.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _summary,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}