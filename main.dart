import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MaterialApp(home: HomeScreen(), debugShowCheckedModeBanner: false));

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  String _text = '';
  bool _loading = false;

  Future<void> _gen() async {
    if (_controller.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse('https://leingpt.ru/api/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer lein_aCAQYbCbY4KFx3gr8Lgmp6s4uvX7RfKWGFoiuX9evlw',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [{'role': 'user', 'content': 'Напиши сценарий для короткого видео: ' + _controller.text}],
        }),
      );
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      setState(() => _text = data['choices'][0]['message']['content'] ?? '');
    } catch (e) {
      setState(() => _text = 'Ошибка: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScriptFlow AI')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _controller, decoration: const InputDecoration(labelText: 'Тема сценария')),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _loading ? null : _gen, child: const Text('Сгенерировать')),
            const SizedBox(height: 10),
            if (_text.isNotEmpty)
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrompterPage(text: _text))),
                child: const Text('Открыть суфлёр 🎬'),
              ),
            const SizedBox(height: 10),
            Expanded(child: SingleChildScrollView(child: Text(_text))),
          ],
        ),
      ),
    );
  }
}

class PrompterPage extends StatefulWidget {
  final String text;
  const PrompterPage({super.key, required this.text});
  @override
  State<PrompterPage> createState() => _PrompterPageState();
}

class _PrompterPageState extends State<PrompterPage> {
  final _scroll = ScrollController();
  bool _run = false;

  void _scrollLoop() async {
    while (_run && _scroll.hasClients) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!_run || !_scroll.hasClients) break;
      _scroll.jumpTo(_scroll.offset + 2.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _run = !_run);
          if (_run) _scrollLoop();
        },
        child: Icon(_run ? Icons.pause : Icons.play_arrow),
      ),
      body: SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.all(20),
        child: Text(widget.text, style: const TextStyle(color: Colors.white, fontSize: 28)),
      ),
    );
  }
}
