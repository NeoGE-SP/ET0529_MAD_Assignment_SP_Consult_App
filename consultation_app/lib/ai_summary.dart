import 'dart:convert';
import 'dart:async'; 
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
        'content': 'You are a helpful assistant that summarizes the important parts of the text in brief bullet points form. If notes do not make sense or is empty, simply respond with blank. Refrain from using characters that are meant to change the way your respond looks'
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
  String _summary1 = "";
  String _summary2 = "";
  String s_notes = "";
  String l_notes = "";
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    print("init state started");
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        setState(() {
          s_notes = args['s_notes'] ?? "";
          l_notes = args['l_notes'] ?? "";
          print(s_notes);
          print(l_notes);
        });

        summarizeNote1(s_notes);
        summarizeNote2(l_notes);
        print(_loading);
      } else {
        setState(() => _loading = false);
      }
    });
  }

  Future<void> summarizeNote1(s_notes) async {

    setState(() {
      _summary1 = "";
    });

    try {
      final result = await getOpenRouterResponse(s_notes);
      setState(() {
        _summary1 = result;
      });
    } catch (e) {
      setState(() {
        _summary1 = "Error: $e";
      });
    } 
  }

  Future<void> summarizeNote2(l_notes) async {

    setState(() {
      _summary2 = "";
    });

    try {
      final result = await getOpenRouterResponse(l_notes);
      setState(() {
        _summary2 = result;
      });
    } catch (e) {
      setState(() {
        _summary2 = "Error: $e";
        _loading = false;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Image.asset('assets/img/sp_logo.png', height: 40, fit: BoxFit.contain,),
        shape: Border(
          bottom: BorderSide(
            color: const Color.fromARGB(255, 195, 195, 195),
            width: 2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: const Text(
                      'AI Summary',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
              ),
              const SizedBox(height: 16),
              const Text("Student's notes"),
              const SizedBox(height: 6,),
              if (_summary1.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _summary1,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16,),
                const Text("Lecturer's notes"),
                const SizedBox(height: 6,),
                if (_summary2.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _summary2,
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