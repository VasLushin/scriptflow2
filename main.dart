import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ScriptFlowApp());
}

class ScriptFlowApp extends StatelessWidget {
  const ScriptFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScriptFlow Studio AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D111A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFB300),
          secondary: Color(0xFF6366F1),
          surface: Color(0xFF161D2B),
        ),
      ),
      home: const MainStudioScreen(),
    );
  }
}

class SavedProject {
  final String id;
  final String title;
  final String format;
  final String content;
  final DateTime date;

  SavedProject({
    required this.id,
    required this.title,
    required this.format,
    required this.content,
    required this.date,
  });
}

class MainStudioScreen extends StatefulWidget {
  const MainStudioScreen({super.key});

  @override
  State<MainStudioScreen> createState() => _MainStudioScreenState();
}

class _MainStudioScreenState extends State<MainStudioScreen> {
  final TextEditingController _topicController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedFormat = 'Короткий хук (Shorts)';
  String _selectedTone = 'Интригующий';
  int _targetSeconds = 45;

  bool _isPro = false;
  bool _isLoading = false;
  String _generatedScript = '';
  List<String> _alternateHooks = [];

  final List<SavedProject> _savedProjects = [];

  final List<String> _formats = [
    'Короткий хук (Shorts)',
    'Вирусный сторителлинг',
    'ТОП-3 / Разбор мифов',
    'Продающий / Экспертный',
    'Глубокая драма / Кино'
  ];

  final List<String> _tones = [
    'Интригующий',
    'Провокационный',
    'Юмористический',
    'Экспертный и строгий',
    'Кинематографичный'
  ];

  final List<String> _topicIdeas = [
    'Почему умные люди часто остаются бедными',
    '3 привычки, разрушающие дисциплину по утрам',
    'Как говорить нет без чувства вины',
    'Что скрывают производители дешёвых продуктов',
    'Главная ошибка при переговорах о зарплате',
    'Секретный психологический трюк спецслужб'
  ];

  @override
  void dispose() {
    _topicController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int _calculateSpeakingSeconds(String text) {
    if (text.trim().isEmpty) return 0;
    final words = text.trim().split(RegExp(r'\s+')).length;
    return max(1, (words / 2.2).round());
  }

  Future<void> _generateScript() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      _showSnack('Введите тему ролика или выберите идею ниже!', Colors.orangeAccent);
      return;
    }

    setState(() {
      _isLoading = true;
      _generatedScript = '';
      _alternateHooks = [];
    });

    FocusScope.of(context).unfocus();

    String resultScript = '';

    // Запрос в онлайн API с расширенным таймаутом
    try {
      final prompt = 'Ты топовый продюсер и сценарист YouTube Shorts, Reels и TikTok. '
          'Напиши совершенно уникальный, живой, реалистичный сценарий на тему: "$topic". '
          'Формат: $_selectedFormat. Тональность: $_selectedTone. '
          'Требования: никакой воды, яркая кинематографичная речь, реальные инсайты, '
          'четкая драматургия с неожиданным поворотом и призывом к действию.';

      final response = await http.post(
        Uri.parse('https://leingpt.ru/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'model': 'yandexgpt',
          'temperature': 0.85,
        }),
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final rawText = data['text'] ?? data['result'] ?? '';
        if (rawText.toString().trim().length > 60) {
          resultScript = rawText.toString().trim();
        }
      }
    } catch (_) {}

    // Если нет связи, срабатывает богатый вариативный оффлайн-двигатель
    if (resultScript.trim().isEmpty) {
      resultScript = _buildRichDiverseScript(topic, _selectedFormat, _selectedTone);
    }

    _alternateHooks = _buildCreativeHooks(topic, _selectedTone);

    setState(() {
      _generatedScript = resultScript;
      _isLoading = false;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Разнообразный генератор с множеством сюжетных структур
  String _buildRichDiverseScript(String topic, String format, String tone) {
    final rng = Random();

    if (format.contains('ТОП-3')) {
      final facts = [
        '1. Скрытый триггер: мы реагируем не на логику, а на мгновенный дофаминовый стимул.\n'
        '2. Синдром ложного контроля: 80% попыток исправить это старыми методами только усугубляют проблему.\n'
        '3. Решающий рычаг: одно простое правило микро-действий меняет траекторию уже через неделю.',

        '1. Правило первого часа: то, куда уходит ваше внимание утром, определяет доход месяца.\n'
        '2. Избавление от информационного шума: 90% потребляемого контента блокирует критическое мышление.\n'
        '3. Фиксация результата: отсутствие прозрачных цифр гарантирует возврат к нулю.',

        '1. Ловушка лёгких путей: быстрые результаты почти всегда ведут к откату назад.\n'
        '2. Окружение и скрытые якоря: пока вокруг вас люди без целей, вы неосознанно копируете их планку.\n'
        '3. Безжалостный аудит привычек: уберите всего одно деструктивное действие, и результат удвоится.'
      ];
      final chosenFacts = facts[rng.nextInt(facts.length)];

      return '🎬 [ХУК: ТОП-3]\n'
          'Три вещи про $topic, о которых вам никогда не расскажут бесплатно:\n\n'
          '🔥 [РАЗБОР ПО ПУНКТАМ]\n$chosenFacts\n\n'
          '🚀 [ФИНАЛ]\n'
          'Какой из этих трёх пунктов для вас самый сложный? Напишите номер в комментариях!';
    }

    if (format.contains('сторителлинг') || format.contains('Кино')) {
      final stories = [
        'В 1994 году провели эксперимент, результаты которого засекретили на 15 лет. '
        'Группу добровольцев поместили в условия, напрямую связанные с темой: $topic. '
        'Уже на четвёртый день учёные заметили аномалию: человеческий мозг начал перестраивать восприятие реальности. '
        'И вот к какому шокирующему выводу они пришли: дело было вообще не в генетике или удаче. '
        'Всё упиралось в один-единственный внутренний алгоритм принятия решений.',

        'Представь человека, который потерял всё из-за одной неочевидной ошибки в теме $topic. '
        'Он потратил годы, пытаясь всё исправить стандартными методами, пока случайно не заметил странную деталь. '
        'Как только он изменил всего одну переменную в уравнении — система мгновенно заработала в обратную сторону. '
        'Сегодня этот же принцип используют топовые мировые лидеры, хотя вслух о нём почти не говорят.',

        'Если бы пять лет назад мне показали реальные данные про $topic, я бы не поверил ни единому слову. '
        'Мы привыкли смотреть на верхушку айсберга и судить по красивой картинке. '
        'Но когда вы заглядываете за кулисы и видите реальные механизмы — иллюзии испаряются за секунду. '
        'И сейчас я покажу вам, как работает эта механика без прикрас.'
      ];
      final chosenStory = stories[rng.nextInt(stories.length)];

      return '🎬 [КИНЕМАТОГРАФИЧНЫЙ ХУК]\n'
          'Эта история изменит то, как вы смотрите на $topic, раз и навсегда...\n\n'
          '🔥 [ДРАМАТУРГИЯ]\n$chosenStory\n\n'
          '🚀 [ИНСАЙТ И ВЫВОД]\n'
          'Задайте себе этот вопрос прямо сейчас. И если хотите продолжение расследования — подпишитесь на канал!';
    }

    // Стандартный взрывной экспертный хук
    final hooks = [
      'Перестаньте совершать эту ошибку, если тема $topic для вас действительно важна!',
      'То, что вам годами внушали про $topic — это опасное заблуждение.',
      'Почему одни забирают всё в вопросе "$topic", а другие остаются у разбитого корыта?',
      'Если бы у меня была всего одна минута, чтобы объяснить суть темы $topic, я бы сказал это...'
    ];

    final cores = [
      'Большинство пытается бороться со следствием, полностью игнорируя первопричину.\n'
      'Запомните фундаментальный закон: пока у вас нет чёткой структуры, любые усилия превращаются в хаос.\n'
      'Сфокусируйтесь на главном рычаге давления — и всё остальное подтянется автоматически.',

      'Разница между любителем и профессионалом всегда в деталях.\n'
      'Пока любитель надеется на вдохновение и случай, профессионал выстраивает повторяемую систему.\n'
      'В теме $topic побеждают не самые громкие, а самые последовательные.',

      'Мы живём в эпоху тотального перегруза информацией.\n'
      'Умение отсекать 95% бесполезных советов по теме $topic — это единственный навык, который даёт осязаемый результат прямо сегодня.'
    ];

    final ctas = [
      'Сохраните в закладки, чтобы пересмотреть в нужный момент, и перешлите тому, кто в теме!',
      'Напишите в комментариях: согласны с этим подходом или у вас другой опыт?',
      'Жмите подписку — завтра разберём следующую неочевидную ловушку!'
    ];

    return '🎬 [ВЗРЫВНОЙ ХУК]\n${hooks[rng.nextInt(hooks.length)]}\n\n'
        '🔥 [СУТЬ БЕЗ ВОДЫ]\n${cores[rng.nextInt(cores.length)]}\n\n'
        '🚀 [ПРИЗЫВ К ДЕЙСТВИЮ]\n${ctas[rng.nextInt(ctas.length)]}';
  }

  List<String> _buildCreativeHooks(String topic, String tone) {
    return [
      '⚡ «Никогда не делайте этого, если хотите преуспеть в: $topic...»',
      '👀 «Я проверил главное правило про $topic на практике, и результат меня шокировал!»',
      '🛑 «9 из 10 людей пролистают это видео, но если вы останетесь — вы поймёте всё про $topic.»',
    ];
  }

  void _saveToProjects() {
    if (_generatedScript.isEmpty) return;
    final project = SavedProject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _topicController.text.trim().isNotEmpty
          ? _topicController.text.trim()
          : 'Сценарий от ${_formatDate(DateTime.now())}',
      format: _selectedFormat,
      content: _generatedScript,
      date: DateTime.now(),
    );

    setState(() {
      _savedProjects.insert(0, project);
    });

    _showSnack('Проект сохранён в папку избранного! 💾', Colors.greenAccent);
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')} ${dt.hour}:${dt.minute}';
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: color.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openTeleprompter(String text) {
    if (text.trim().isEmpty) {
      _showSnack('Сначала сгенерируйте сценарий!', Colors.orangeAccent);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeleprompterScreen(scriptText: text),
      ),
    );
  }

  void _openSavedProjectsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141923),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '📂 Сохранённые проекты',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_savedProjects.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Нет сохранённых проектов.\nНажмите иконку закладки после генерации!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _savedProjects.length,
                        itemBuilder: (context, index) {
                          final p = _savedProjects[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2638),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        p.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amberAccent),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () {
                                        setModalState(() {
                                          _savedProjects.removeAt(index);
                                        });
                                        setState(() {});
                                      },
                                    )
                                  ],
                                ),
                                Text(p.format, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 8),
                                Text(
                                  p.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _openTeleprompter(p.content);
                                      },
                                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                                      label: const Text('Суфлёр'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFFB300),
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: p.content));
                                        _showSnack('Скопировано в буфер!', Colors.blueAccent);
                                      },
                                      icon: const Icon(Icons.copy, size: 16, color: Colors.white70),
                                      label: const Text('Копировать', style: TextStyle(color: Colors.white70)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.white24),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openProModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141923),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ProBillingModal(
        isPro: _isPro,
        onProActivated: () {
          setState(() {
            _isPro = true;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final speakingSeconds = _calculateSpeakingSeconds(_generatedScript);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D111A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.movie_creation_rounded, color: Color(0xFFFFB300), size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ScriptFlow', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19, letterSpacing: 0.5)),
                Text(
                  _isPro ? 'PRO UNLIMITED ✨' : 'STUDIO EDITION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _isPro ? const Color(0xFFFFB300) : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_special_rounded, color: Colors.white70),
            tooltip: 'Проекты',
            onPressed: _openSavedProjectsModal,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: _openProModal,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isPro
                        ? [const Color(0xFFFFB300), const Color(0xFFFF8F00)]
                        : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(_isPro ? Icons.star_rounded : Icons.lock_open_rounded, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      _isPro ? 'VIP' : 'ТАРИФЫ',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('О чём снимаем ролик?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161D2B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: TextField(
                controller: _topicController,
                maxLines: 3,
                style: const TextStyle(fontSize: 15, color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Например: 3 привычки, убивающие фокус или Как начать инвестировать с нуля...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _topicIdeas.map((idea) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      backgroundColor: const Color(0xFF1E2638),
                      label: Text(idea, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onPressed: () {
                        setState(() {
                          _topicController.text = idea;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Формат', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161D2B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedFormat,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF161D2B),
                            items: _formats.map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (v) => setState(() => _selectedFormat = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Тональность', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161D2B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedTone,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF161D2B),
                            items: _tones.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (v) => setState(() => _selectedTone = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateScript,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB300),
                  foregroundColor: Colors.black,
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black)),
                          SizedBox(width: 14),
                          Text('СОЗДАЁМ СЦЕНАРИЙ...', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 22, color: Colors.black),
                          SizedBox(width: 10),
                          Text('СГЕНЕРИРОВАТЬ СЦЕНАРИЙ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            if (_generatedScript.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2638),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: Color(0xFFFFB300), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Хронометраж речи: ~$speakingSeconds сек. (${_generatedScript.split(RegExp(r'\s+')).length} слов)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                          ),
                          Text(
                            speakingSeconds <= 60
                                ? '✅ Идеально для Shorts, TikTok и Reels (< 60с)'
                                : '⚠️ Формат для глубокого сторителлинга (> 60с)',
                            style: TextStyle(
                              fontSize: 12,
                              color: speakingSeconds <= 60 ? Colors.greenAccent : Colors.orangeAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              if (_alternateHooks.isNotEmpty) ...[
                const Text('🔥 Выберите альтернативный хук:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
                const SizedBox(height: 8),
                ..._alternateHooks.map((hook) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161D2B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(hook, style: const TextStyle(fontSize: 13, color: Colors.white))),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, color: Colors.amberAccent, size: 18),
                          tooltip: 'Скопировать хук',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: hook));
                            _showSnack('Хук скопирован!', Colors.blueAccent);
                          },
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 14),
              ],

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF161D2B),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Полный текст', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.bookmark_add_outlined, color: Colors.amberAccent),
                              tooltip: 'В избранное',
                              onPressed: _saveToProjects,
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, color: Colors.white70),
                              tooltip: 'Копировать всё',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _generatedScript));
                                _showSnack('Сценарий скопирован!', Colors.blueAccent);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 8),
                    SelectableText(
                      _generatedScript,
                      style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _openTeleprompter(_generatedScript),
                        icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.black, size: 24),
                        label: const Text('ОТКРЫТЬ В ТЕЛЕСУФЛЁРЕ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB300),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ОБНОВЛЕННЫЙ ТЕЛЕСУФЛЁР (БЕЗ ЗЕРКАЛА, С РОВНЫМ ЦЕНТРОМ)
// ==========================================
class TeleprompterScreen extends StatefulWidget {
  final String scriptText;

  const TeleprompterScreen({super.key, required this.scriptText});

  @override
  State<TeleprompterScreen> createState() => _TeleprompterScreenState();
}

class _TeleprompterScreenState extends State<TeleprompterScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  bool _isPlaying = false;
  int _countdown = 0;
  Timer? _countdownTimer;

  double _scrollSpeed = 2.0;
  double _fontSize = 28.0;
  bool _showFocusLine = true; // Кнопка переключения полосы фокуса

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _countdownTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_isPlaying) {
      _stopScroll();
    } else {
      _startCountdown();
    }
  }

  void _startCountdown() {
    setState(() {
      _countdown = 3;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });
      if (_countdown <= 0) {
        timer.cancel();
        _startScroll();
      }
    });
  }

  void _startScroll() {
    setState(() {
      _isPlaying = true;
    });

    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!_scrollController.hasClients) return;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;

      if (current >= maxScroll) {
        _stopScroll();
      } else {
        _scrollController.jumpTo(current + _scrollSpeed);
      }
    });
  }

  void _stopScroll() {
    _scrollTimer?.cancel();
    _countdownTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _countdown = 0;
    });
  }

  void _resetToTop() {
    _stopScroll();
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Основной текст
          GestureDetector(
            onTap: _togglePlay,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: MediaQuery.of(context).size.height * 0.45,
              ),
              child: Text(
                widget.scriptText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // ИДЕАЛЬНО ОТЦЕНТРИРОВАННАЯ ЛИНИЯ ФОКУСА
          if (_showFocusLine)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.40,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: const Color(0xFFFFB300).withOpacity(0.35),
                        width: 1.5,
                      ),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFFFFB300).withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Обратный отсчёт 3..2..1
          if (_countdown > 0)
            Center(
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFB300), width: 3),
                  ),
                  child: Text(
                    '$_countdown',
                    style: const TextStyle(fontSize: 70, fontWeight: FontWeight.w900, color: Color(0xFFFFB300)),
                  ),
                ),
              ),
            ),

          // Верхняя панель: Назад, Вкл/Выкл полосы, Сброс
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.6),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Row(
                    children: [
                      // Кнопка включения/выключения полосы взгляда
                      CircleAvatar(
                        backgroundColor: _showFocusLine ? const Color(0xFFFFB300) : Colors.black.withOpacity(0.6),
                        child: IconButton(
                          icon: Icon(
                            _showFocusLine ? Icons.remove_red_eye_rounded : Icons.visibility_off_rounded,
                            color: _showFocusLine ? Colors.black : Colors.white70,
                            size: 20,
                          ),
                          tooltip: 'Линия взгляда',
                          onPressed: () => setState(() => _showFocusLine = !_showFocusLine),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Перезапуск наверх
                      CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.6),
                        child: IconButton(
                          icon: const Icon(Icons.replay_rounded, color: Colors.white),
                          tooltip: 'В начало',
                          onPressed: _resetToTop,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // Нижняя панель настроек
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF141923).withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.speed_rounded, color: Colors.amberAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Slider(
                            value: _scrollSpeed,
                            min: 0.5,
                            max: 6.0,
                            activeColor: const Color(0xFFFFB300),
                            inactiveColor: Colors.white24,
                            onChanged: (v) {
                              setState(() => _scrollSpeed = v);
                              if (_isPlaying) _startScroll();
                            },
                          ),
                        ),
                        Text('${_scrollSpeed.toStringAsFixed(1)}x', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.format_size_rounded, color: Colors.amberAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Slider(
                            value: _fontSize,
                            min: 18.0,
                            max: 48.0,
                            activeColor: const Color(0xFFFFB300),
                            inactiveColor: Colors.white24,
                            onChanged: (v) => setState(() => _fontSize = v),
                          ),
                        ),
                        Text('${_fontSize.toInt()}pt', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _togglePlay,
                        icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.black, size: 28),
                        label: Text(
                          _isPlaying ? 'ПАУЗА (ТАП ПО ЭКРАНУ)' : 'СТАРТ СУФЛЁРА',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB300),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// МОДАЛКА ТАРИФОВ (ПЕРЕХОД К ОПЛАТЕ ЧЕРЕЗ БОТА)
// ==========================================
class ProBillingModal extends StatefulWidget {
  final bool isPro;
  final VoidCallback onProActivated;

  const ProBillingModal({super.key, required this.isPro, required this.onProActivated});

  @override
  State<ProBillingModal> createState() => _ProBillingModalState();
}

class _ProBillingModalState extends State<ProBillingModal> {
  final TextEditingController _promoController = TextEditingController();
  int _selectedTariffIndex = 1;

  final List<Map<String, dynamic>> _tariffs = [
    {
      'title': '1 Месяц Studio',
      'price': '490 ₽',
      'oldPrice': '890 ₽',
      'desc': 'Полный доступ к AI-моделям и суфлёру',
      'badge': null,
    },
    {
      'title': 'Навсегда VIP Lifetime',
      'price': '1 290 ₽',
      'oldPrice': '3 490 ₽',
      'desc': 'Разовый платёж. Все будущие обновления включены',
      'badge': 'ХИТ ПРОДАЖ',
    },
  ];

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) {
      _showMsg('Введите промокод!');
      return;
    }

    final validCodes = ['PRO2026', 'SCRIPTFLOW', 'VIP', 'LEIN'];
    if (validCodes.contains(code)) {
      widget.onProActivated();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Промокод активирован! VIP-доступ предоставлен.'),
          backgroundColor: Color(0xFF1E2638),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _showMsg('Неверный промокод.');
    }
  }

  // Переход на официальную оплату через Telegram
  void _openRealPayment() {
    const telegramUrl = 'https://t.me/LeinAIbot';
    Clipboard.setData(const ClipboardData(text: telegramUrl));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2638),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.lock_person_rounded, color: Color(0xFFFFB300)),
            SizedBox(width: 10),
            Text('Оплата через бота', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Тариф: ${_tariffs[_selectedTariffIndex]['title']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent)),
            const SizedBox(height: 6),
            Text('Стоимость: ${_tariffs[_selectedTariffIndex]['price']}', style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            const Text(
              'Для завершения оплаты перейдите в официальный бот @LeinAIbot в Telegram. '
              'После оплаты вы получите персональный ключ активации.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ссылка @LeinAIbot скопирована в буфер обмена! Перейдите в Telegram.'),
                  backgroundColor: Color(0xFF1E2638),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.send_rounded, size: 16, color: Colors.black),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB300),
              foregroundColor: Colors.black,
            ),
            label: const Text('Перейти к оплате', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _showMsg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('💎 Тарифы ScriptFlow Pro', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),

          ...List.generate(_tariffs.length, (i) {
            final t = _tariffs[i];
            final isSelected = _selectedTariffIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedTariffIndex = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFB300).withOpacity(0.12) : const Color(0xFF1A2232),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFFB300) : Colors.white.withOpacity(0.08),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? const Color(0xFFFFB300) : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(t['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                              if (t['badge'] != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFB300),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(t['badge'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
                                ),
                              ]
                            ],
                          ),
                          Text(t['desc'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(t['price'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.amberAccent)),
                        Text(t['oldPrice'], style: const TextStyle(fontSize: 11, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                      ],
                    )
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2232),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TextField(
                    controller: _promoController,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: 'Промокод / Ключ активации',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _applyPromo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B354C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Применить', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _openRealPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300),
                foregroundColor: Colors.black,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('ПЕРЕЙТИ К ОПЛАТЕ ТАРИФА', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}
