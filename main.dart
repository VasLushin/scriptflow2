import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF090D16),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const ScriptFlowProApp());
}

class ScriptFlowProApp extends StatelessWidget {
  const ScriptFlowProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScriptFlow AI Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090D16),
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF131B2E),
        ),
      ),
      home: const MainStudioScreen(),
    );
  }
}

class MainStudioScreen extends StatefulWidget {
  const MainStudioScreen({super.key});

  @override
  State<MainStudioScreen> createState() => _MainStudioScreenState();
}

class _MainStudioScreenState extends State<MainStudioScreen> {
  final TextEditingController _topicController = TextEditingController();
  int _selectedFormatIndex = 0;
  int _selectedToneIndex = 0;
  bool _isLoading = false;
  String _generatedScript = '';

  final List<Map<String, dynamic>> _formats = [
    {'title': 'Хук на 3 сек', 'sub': 'Вирусный захват', 'icon': Icons.bolt, 'tag': 'Виральный хук (первые 3-5 секунд с шок-фактом)'},
    {'title': 'Shorts / Reels', 'sub': 'Сценарий 60 сек', 'icon': Icons.timer, 'tag': 'Сценарий для 60 секунд (хук, кульминация, финал)'},
    {'title': 'Сторителлинг', 'sub': 'Архивный сюжет', 'icon': Icons.menu_book, 'tag': 'Кинематографичный сторителлинг с драматической интригой'},
    {'title': 'Топ-3 факта', 'sub': 'Динамичный разбор', 'icon': Icons.format_list_numbered, 'tag': 'Топ-3 невероятных факта с интригой в конце'},
  ];

  final List<String> _tones = [
    '🔥 Драматичный',
    '⚡ Динамичный',
    '📜 Архивный / Док',
    '😏 Сарказм / Ирония',
  ];

  Future<void> _generate() async {
    final query = _topicController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Введите тему или идею для ролика'),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _generatedScript = '';
    });

    final format = _formats[_selectedFormatIndex]['tag'];
    final tone = _tones[_selectedToneIndex];

    final prompt = '''Ты — топ-сценарист вирусных вертикальных видео для TikTok, Reels и YouTube Shorts с миллионными охватами.
Напиши сценарий на тему: "$query".
Формат: $format.
Тон повествования: $tone.

Требования:
- Текст должен легко читаться в телесуфлёре.
- Без лишней воды, сразу мощное зацепляющее начало.
- Раздели на смысловые логические блоки: [ХУК], [ОСНОВНАЯ ЧАСТЬ], [РАЗВЯЗКА/CTA].
- Добавь в скобках короткие ремарки для диктора: (пауза), (акцент голосом).''';

    try {
      final response = await http.post(
        Uri.parse('https://leingpt.ru/api/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer lein_aCAQYbCbY4KFx3gr8Lgmp6s4uvX7RfKWGFoiuX9evlw',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': 'Ты профессиональный киносценарист и режиссёр вирусных вертикальных форматов.'},
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.75,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _generatedScript = data['choices'][0]['message']['content'] ?? '';
        });
      } else {
        setState(() {
          _generatedScript = 'Ошибка сервера [HTTP ${response.statusCode}]. Проверьте баланс ключа или повторите попытку.';
        });
      }
    } catch (e) {
      setState(() {
        _generatedScript = 'Ошибка подключения к сети: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -0.9),
            radius: 1.5,
            colors: [
              Color(0xFF1E1E38),
              Color(0xFF090D16),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildInputCard(),
                    const SizedBox(height: 20),
                    _buildFormatSelector(),
                    const SizedBox(height: 20),
                    _buildToneSelector(),
                    const SizedBox(height: 24),
                    _buildGenerateButton(),
                    const SizedBox(height: 24),
                    if (_isLoading) _buildLoadingCard(),
                    if (_generatedScript.isNotEmpty && !_isLoading) _buildResultCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'SCRIPTFLOW',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'AI STUDIO PRO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              children: const [
                Icon(Icons.workspace_premium, color: Color(0xFFF59E0B), size: 16),
                SizedBox(width: 6),
                Text('PRO', style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF222F4C)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ИДЕЯ ИЛИ ТЕМА',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Color(0xFF94A3B8),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _topicController.text = 'Секретная операция КГБ: как фальшивый майор обманул всё правительство СССР';
                },
                child: const Text(
                  'Пример 💡',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _topicController,
            maxLines: 3,
            minLines: 2,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
            decoration: InputDecoration(
              hintText: 'О чём ролик? (например: Тайна перевала Дятлова, топ афер СССР...)',
              hintStyle: const TextStyle(color: Color(0xFF475569), fontSize: 14),
              filled: true,
              fillColor: const Color(0xFF0C1322),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'ФОРМАТ РОЛИКА',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.1,
          ),
          itemCount: _formats.length,
          itemBuilder: (context, index) {
            final f = _formats[index];
            final isSelected = _selectedFormatIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedFormatIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E2640) : const Color(0xFF131B2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF222F4C),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Icon(
                      f['icon'],
                      color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            f['title'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            f['sub'],
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildToneSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'СТИЛЬ ПОДАЧИ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _tones.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedToneIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedToneIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF131B2E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF818CF8) : const Color(0xFF222F4C),
                    ),
                  ),
                  child: Text(
                    _tones[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _generate,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flash_on, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              _isLoading ? 'НЕЙРОСЕТЬ ПИШЕТ СЦЕНАРИЙ...' : 'СОЗДАТЬ СЦЕНАРИЙ ✨',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF222F4C)),
      ),
      child: Column(
        children: const [
          CircularProgressIndicator(color: Color(0xFF6366F1), strokeWidth: 3),
          SizedBox(height: 16),
          Text(
            'Генерация сценария и хука...',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 6),
          Text(
            'Подбираем темп и ключевые акценты для суфлёра',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'СЦЕНАРИЙ ГОТОВ',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Color(0xFF94A3B8), size: 20),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _generatedScript));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Текст скопирован в буфер!'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      tooltip: 'Скопировать',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF222F4C)),
          Padding(
            padding: const EdgeInsets.all(18),
            child: SelectableText(
              _generatedScript,
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              icon: const Icon(Icons.play_circle_filled, size: 22, color: Colors.black),
              label: const Text(
                'ОТКРЫТЬ В ТЕЛЕСУФЛЁРЕ 🎬',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.8),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StudioTeleprompterScreen(scriptText: _generatedScript)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StudioTeleprompterScreen extends StatefulWidget {
  final String scriptText;
  const StudioTeleprompterScreen({super.key, required this.scriptText});

  @override
  State<StudioTeleprompterScreen> createState() => _StudioTeleprompterScreenState();
}

class _StudioTeleprompterScreenState extends State<StudioTeleprompterScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isPlaying = false;
  double _speed = 2.0;
  double _fontSize = 32.0;
  bool _isMirrored = false;

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _runAutoScroll();
    }
  }

  void _runAutoScroll() async {
    while (_isPlaying && _scrollController.hasClients) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!_isPlaying || !_scrollController.hasClients) break;
      final max = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;
      if (current >= max) {
        setState(() => _isPlaying = false);
        break;
      }
      _scrollController.jumpTo(current + (_speed * 0.45));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: _togglePlay,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..scale(_isMirrored ? -1.0 : 1.0, 1.0),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 70),
                  child: Text(
                    widget.scriptText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _fontSize,
                      fontWeight: FontWeight.w800,
                      height: 1.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.text_decrease, color: Colors.white, size: 18),
                              onPressed: () => setState(() => _fontSize = (_fontSize - 2).clamp(20.0, 54.0)),
                            ),
                            Text('${_fontSize.toInt()}pt', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.text_increase, color: Colors.white, size: 18),
                              onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(20.0, 54.0)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: _isMirrored ? const Color(0xFF6366F1) : Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.flip, color: Colors.white, size: 20),
                          onPressed: () => setState(() => _isMirrored = !_isMirrored),
                          tooltip: 'Зеркальный режим для стекла',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF131B2E).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF334155)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _isPlaying ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 26),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.speed, color: Color(0xFF94A3B8), size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Slider(
                        value: _speed,
                        min: 0.5,
                        max: 8.0,
                        activeColor: const Color(0xFF6366F1),
                        inactiveColor: const Color(0xFF334155),
                        onChanged: (val) => setState(() => _speed = val),
                      ),
                    ),
                    Text(
                      '${_speed.toStringAsFixed(1)}x',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
